const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const file = try std.fs.cwd().openFile("input/day06.txt", .{});
    defer file.close();
    const stat = try file.stat();
    const input = try file.readToEndAlloc(allocator, stat.size);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    const times_line = lines.next() orelse unreachable;
    const distances_line = lines.next() orelse unreachable;

    var times = std.mem.tokenizeScalar(u8, times_line, ' ');
    var distances = std.mem.tokenizeScalar(u8, distances_line, ' ');

    _ = times.next();
    _ = distances.next();

    var total_part_1: usize = 1;

    var time_part_2: usize = 0;
    var distance_part_2: usize = 0;

    while (times.next()) |time_str| {
        const distance_str = distances.next() orelse unreachable;

        const time = try std.fmt.parseInt(usize, time_str, 10);
        const distance = try std.fmt.parseInt(usize, distance_str, 10);

        time_part_2 = time_part_2 * (try std.math.powi(usize, 10, time_str.len)) + time;
        distance_part_2 = distance_part_2 * (try std.math.powi(usize, 10, distance_str.len)) + distance;

        total_part_1 *= getPossibleWaysCount(time, distance);
    }

    const total_part_2 = getPossibleWaysCount(time_part_2, distance_part_2);

    std.debug.print("First part: {}\n", .{total_part_1});
    std.debug.print("Second part hey: {}\n", .{total_part_2});
}

fn getPossibleWaysCount(time: usize, distance: usize) usize {
    const time_f: f64 = @floatFromInt(time);
    const distance_f: f64 = @floatFromInt(distance);

    const d2 = time_f * time_f - 4 * distance_f;

    if (d2 < 0) {
        return 0;
    }

    const d = std.math.sqrt(d2);

    const x1 = (time_f - d) / 2;
    const x2 = (time_f + d) / 2;

    const min: usize = @intFromFloat(std.math.floor(x1 + 1));
    const max: usize = @intFromFloat(std.math.ceil(x2 - 1));

    if (min > max) {
        return 0;
    }

    return max - min + 1;
}
