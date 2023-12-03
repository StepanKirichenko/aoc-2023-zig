const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day02.txt", 1024 * 1024);

    var possibleIdsSum: usize = 0;
    var powersSum: usize = 0;

    var lines = std.mem.tokenizeAny(u8, file, "\n");
    while (lines.next()) |line| {
        var subsets = std.mem.tokenizeAny(u8, line, ":;");
        const gameInfo = subsets.next().?;
        const gameId = getGameId(gameInfo);
        var gameColorCount = ColorCount{};
        while (subsets.next()) |subset| {
            const subsetColorCount = analyzeSubset(subset);
            gameColorCount = ColorCount.merge(gameColorCount, subsetColorCount);
        }
        const isGamePossible =
            gameColorCount.red < 12 and gameColorCount.green < 13 and gameColorCount.blue < 14;
        if (isGamePossible) {
            possibleIdsSum += gameId;
        }
        const gamePower = gameColorCount.red * gameColorCount.green * gameColorCount.blue;
        powersSum += gamePower;
    }

    std.debug.print("Part 1: {}\n", .{possibleIdsSum});
    std.debug.print("Part 2: {}\n", .{powersSum});
}

fn getGameId(gameInfo: []const u8) usize {
    var tokens = std.mem.tokenizeAny(u8, gameInfo, " ");
    _ = tokens.next(); // Skip "Game"
    const idString = tokens.next().?;
    return std.fmt.parseInt(usize, idString, 10) catch 0;
}

const ColorCount = struct {
    red: usize = 0,
    green: usize = 0,
    blue: usize = 0,

    pub fn merge(a: ColorCount, b: ColorCount) ColorCount {
        return .{
            .red = max(a.red, b.red),
            .green = max(a.green, b.green),
            .blue = max(a.blue, b.blue),
        };
    }
};

fn analyzeSubset(subsetString: []const u8) ColorCount {
    var colors = std.mem.tokenizeAny(u8, subsetString, ",");
    var subsetColorCount = ColorCount{};
    while (colors.next()) |colorInfo| {
        const colorCount = getColorCount(colorInfo);
        subsetColorCount = ColorCount.merge(subsetColorCount, colorCount);
    }
    return subsetColorCount;
}

fn getColorCount(string: []const u8) ColorCount {
    const trimmedString = std.mem.trim(u8, string, " ");
    var tokens = std.mem.tokenizeAny(u8, trimmedString, " ");
    const countString = tokens.next().?;
    const colorString = tokens.next().?;
    const count = std.fmt.parseInt(usize, countString, 10) catch 0;

    if (streq(colorString, "red")) {
        return .{ .red = count };
    } else if (streq(colorString, "green")) {
        return .{ .green = count };
    } else {
        return .{ .blue = count };
    }
}

fn max(a: usize, b: usize) usize {
    return if (a >= b) a else b;
}

fn streq(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}
