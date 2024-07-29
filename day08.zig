const std = @import("std");
const stdout = std.io.getStdOut().writer();

const Error = error{
    NoDirectionsProvided,
    InvalidNodeFormat,
    NodeNotFound,
};

const NodeName = []const u8;

const Node = struct {
    left: NodeName,
    right: NodeName,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const file = try std.fs.cwd().openFile("input/day08.txt", .{});
    const stat = try file.stat();
    const input = try file.readToEndAlloc(allocator, stat.size);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    const directions = lines.next() orelse return Error.NoDirectionsProvided;
    if (directions.len == 0) {
        return Error.NoDirectionsProvided;
    }

    var nodes = std.StringHashMap(Node).init(allocator);
    var ghost_nodes = std.ArrayList(NodeName).init(allocator);
    while (lines.next()) |line| {
        var tokens = std.mem.tokenizeAny(u8, line, " =(,)");
        const node_name = try getNodeName(tokens.next());
        const left = try getNodeName(tokens.next());
        const right = try getNodeName(tokens.next());

        const node = Node{
            .left = left,
            .right = right,
        };

        try nodes.put(node_name, node);

        if (isANode(node_name)) {
            try ghost_nodes.append(node_name);
        }
    }

    var current_node_name: NodeName = "AAA";
    const destination_node_name: NodeName = "ZZZ";
    var direction_index: usize = 0;
    var path_length_1: usize = 0;

    while (!std.mem.eql(u8, current_node_name, destination_node_name)) {
        const current_node = nodes.get(current_node_name) orelse return Error.NodeNotFound;
        const next_node_name = if (directions[direction_index] == 'L') current_node.left else current_node.right;
        current_node_name = next_node_name;
        path_length_1 += 1;
        direction_index += 1;
        if (direction_index >= directions.len) {
            direction_index = 0;
        }
    }

    direction_index = 0;

    var loop_lenghts = std.ArrayList(usize).init(allocator);
    try loop_lenghts.appendNTimes(0, ghost_nodes.items.len);

    var i: usize = 0;

    loop: while (true) {
        defer i += 1;
        for (ghost_nodes.items, 0..) |*node_name, node_index| {
            const node = nodes.get(node_name.*) orelse return Error.NodeNotFound;
            const next_node_name = if (directions[direction_index] == 'L') node.left else node.right;
            node_name.* = next_node_name;
            if (isZNode(next_node_name)) {
                loop_lenghts.items[node_index] = i + 1;
            }
            if (allNonZeros(loop_lenghts.items)) {
                break :loop;
            }
        }
        direction_index += 1;
        if (direction_index >= directions.len) {
            direction_index = 0;
        }
    }

    const path_length_2 = lcm(loop_lenghts.items);

    try stdout.print("Part 1: {}\n", .{path_length_1});
    try stdout.print("Part 2: {}\n", .{path_length_2});
}

fn getNodeName(str: ?[]const u8) !NodeName {
    const node_name = str orelse return Error.InvalidNodeFormat;
    if (node_name.len != 3) {
        return Error.InvalidNodeFormat;
    }
    return node_name;
}

fn allNonZeros(nums: []usize) bool {
    for (nums) |num| {
        if (num == 0) return false;
    }
    return true;
}

fn isANode(node_name: NodeName) bool {
    return node_name[node_name.len - 1] == 'A';
}

fn isZNode(node_name: NodeName) bool {
    return node_name[node_name.len - 1] == 'Z';
}

fn allZNodes(node_names: []NodeName) bool {
    for (node_names) |node_name| {
        if (!isZNode(node_name)) {
            return false;
        }
    }
    return true;
}

fn someZNodes(node_names: []NodeName) bool {
    for (node_names) |node_name| {
        if (isZNode(node_name)) {
            return true;
        }
    }
    return false;
}

fn countZNodes(node_names: []NodeName) usize {
    var result: usize = 0;
    for (node_names) |node_name| {
        if (isZNode(node_name)) {
            result += 1;
        }
    }
    return result;
}

fn lcm(nums: []const usize) usize {
    var res: usize = 1;
    for (nums) |num| {
        res = (res * num) / std.math.gcd(res, num);
    }
    return res;
}
