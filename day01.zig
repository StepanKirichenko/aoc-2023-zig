const std = @import("std");

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gp.deinit();
    var allocator = gp.allocator();

    const file = try std.fs.cwd().readFileAlloc(allocator, "input/day01.txt", 1024 * 1024);
    defer allocator.free(file);

    var sum_part1: usize = 0;
    var sum_part2: usize = 0;

    var lines = std.mem.tokenize(u8, file, "\n");
    while (lines.next()) |line| {
        sum_part1 += getCalibrationValueForLine_part1(line);
        sum_part2 += getCalibrationValueForLine_part2(line);
    }

    std.debug.print("Part 1: {}\n", .{sum_part1});
    std.debug.print("Part 2: {}\n", .{sum_part2});
}

fn isDigit(char: u8) bool {
    return char >= '0' and char <= '9';
}

fn getCalibrationValueForLine_part1(line: []const u8) usize {
    var firstDigit: u8 = undefined;
    var lastDigit: u8 = undefined;
    var foundDigit = false;
    for (line) |char| {
        if (!isDigit(char)) continue;
        const digit: u8 = char - '0';
        lastDigit = digit;
        if (!foundDigit) {
            firstDigit = digit;
            foundDigit = true;
        }
    }
    return firstDigit * 10 + lastDigit;
}

const DigitInfo = struct {
    char: []const u8,
    string: []const u8,
};

const digits = [_]DigitInfo{
    .{ .char = "0", .string = "zero" },
    .{ .char = "1", .string = "one" },
    .{ .char = "2", .string = "two" },
    .{ .char = "3", .string = "three" },
    .{ .char = "4", .string = "four" },
    .{ .char = "5", .string = "five" },
    .{ .char = "6", .string = "six" },
    .{ .char = "7", .string = "seven" },
    .{ .char = "8", .string = "eight" },
    .{ .char = "9", .string = "nine" },
};

fn getCalibrationValueForLine_part2(line: []const u8) usize {
    const startsWith = std.mem.startsWith;
    var firstDigit: u8 = undefined;
    var lastDigit: u8 = undefined;
    var foundDigit = false;
    var index: usize = 0;
    while (index < line.len) : (index += 1) {
        for (digits) |digit| {
            const rest = line[index..];
            if (!startsWith(u8, rest, digit.char) and !startsWith(u8, rest, digit.string)) continue;
            const value = digit.char[0] - '0';
            lastDigit = value;
            if (!foundDigit) {
                foundDigit = true;
                firstDigit = value;
            }
        }
    }
    return firstDigit * 10 + lastDigit;
}
