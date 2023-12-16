const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day04.txt", 1024 * 1024);

    var lines = std.mem.splitAny(u8, file, "\n");
    var set = std.AutoHashMap(usize, void).init(allocator);
    var cardCounts = std.ArrayList(usize).init(allocator);

    var totalPoints: usize = 0;
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        set.clearRetainingCapacity();
        if (cardCounts.items.len <= i) {
            _ = try cardCounts.addOne();
            cardCounts.items[i] = 1;
        }
        const cardStartIndex = std.mem.indexOf(u8, line, ":").? + 1;
        const splitIndex = std.mem.indexOf(u8, line, "|").?;
        const winningNumbersSlice = line[cardStartIndex..splitIndex];
        const actualNumbersSlice = line[splitIndex + 1 ..];

        var winningNumbers = std.mem.tokenizeAny(u8, winningNumbersSlice, " ");
        while (winningNumbers.next()) |numberString| {
            const number = std.fmt.parseInt(usize, numberString, 10) catch continue;
            try set.put(number, {});
        }

        var points: usize = 0;
        var count: usize = 0;
        var actualNumbers = std.mem.tokenizeAny(u8, actualNumbersSlice, " ");
        while (actualNumbers.next()) |numberString| {
            const number = std.fmt.parseInt(usize, numberString, 10) catch continue;
            if (set.get(number) == null) {
                continue;
            }
            count += 1;
            if (points == 0) {
                points = 1;
            } else {
                points *= 2;
            }
        }

        var j: usize = i + 1;
        while (j <= i + count) : (j += 1) {
            if (cardCounts.items.len <= j) {
                _ = try cardCounts.addOne();
                cardCounts.items[j] = 1;
            }
            cardCounts.items[j] += cardCounts.items[i];
        }
        totalPoints += points;
    }

    var totalCards: usize = 0;
    for (cardCounts.items) |c| {
        totalCards += c;
    }

    std.debug.print("Part 1: {}\n", .{totalPoints});
    std.debug.print("Part 1: {}\n", .{totalCards});
}
