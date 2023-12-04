const std = @import("std");

const strArrayList = std.ArrayList([]const u8);
const usizeArrayList = std.ArrayList(usize);

pub fn main() !void {
    std.debug.print("Hello, day 3!\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day03.txt", 1024 * 1024);

    var rows = strArrayList.init(allocator);

    var lines = std.mem.tokenizeAny(u8, file, "\n");
    while (lines.next()) |line| {
        try rows.append(line);
    }

    var sum1: usize = 0;
    var sum2: usize = 0;
    var numbers = usizeArrayList.init(allocator);
    for (rows.items, 0..) |row, rowIndex| {
        for (row, 0..) |char, colIndex| {
            if (!isSymbol(char)) continue;
            numbers.clearRetainingCapacity();
            try getAdjacentNumbers(&rows, &numbers, rowIndex, colIndex);

            for (numbers.items) |number| {
                sum1 += number;
            }

            if (char == '*' and numbers.items.len == 2) {
                sum2 += numbers.items[0] * numbers.items[1];
            }
        }
    }

    std.debug.print("Part 1: {} \n", .{sum1});
    std.debug.print("Part 2: {} \n", .{sum2});
}

fn isSymbol(char: u8) bool {
    return !std.ascii.isDigit(char) and char != '.';
}

fn getNumberAtPos(line: []const u8, pos: isize) ?usize {
    const isDigit = std.ascii.isDigit;

    if (pos < 0 or pos >= line.len) return null;
    const upos: usize = @intCast(pos);

    if (!isDigit(line[upos])) return null;

    var left = upos;
    var right = upos;
    while (left > 0 and isDigit(line[left - 1])) {
        left -= 1;
    }
    while (right < line.len - 1 and isDigit(line[right + 1])) {
        right += 1;
    }

    return std.fmt.parseInt(usize, line[left .. right + 1], 10) catch null;
}

fn getNumbersArondPos(line: []const u8, numbers: *usizeArrayList, pos: usize) !void {
    const centerNumber = getNumberAtPos(line, @intCast(pos));
    if (centerNumber) |number| {
        try numbers.append(number);
    } else {
        const ipos: isize = @intCast(pos);
        for ([_]isize{ -1, 1 }) |offset| {
            if (getNumberAtPos(line, ipos + offset)) |number| {
                try numbers.append((number));
            }
        }
    }
}

fn getAdjacentNumbers(rows: *const strArrayList, numbers: *usizeArrayList, row: usize, col: usize) !void {
    if (row > 0) {
        const upperRow = rows.items[row - 1];
        try getNumbersArondPos(upperRow, numbers, col);
    }
    if (row < rows.items.len - 1) {
        const lowerRow = rows.items[row + 1];
        try getNumbersArondPos(lowerRow, numbers, col);
    }
    const icol: isize = @intCast(col);
    for ([_]isize{ -1, 1 }) |offset| {
        if (getNumberAtPos(rows.items[row], icol + offset)) |number| {
            try numbers.append((number));
        }
    }
}
