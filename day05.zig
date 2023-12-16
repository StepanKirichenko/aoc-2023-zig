const std = @import("std");

const Range = struct {
    start: usize,
    end: usize,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const file = try std.fs.cwd().openFile("input/day05.txt", .{});
    defer file.close();
    const fileStat = try file.stat();
    const input = try file.readToEndAlloc(allocator, fileStat.size);

    var result = std.ArrayList(Range).init(allocator);
    var maps = std.mem.splitSequence(u8, input, "\n\n");

    const seedsLine = maps.next().?;
    var seeds = std.mem.tokenizeAny(u8, seedsLine[7..], " ");
    while (seeds.peek()) |_| {
        const startString = seeds.next().?;
        const lengthString = seeds.next().?;
        const start = try std.fmt.parseInt(usize, startString, 10);
        const length = try std.fmt.parseInt(usize, lengthString, 10);
        try result.append(.{ .start = start, .end = start + length });
    }

    const TransformRange = struct {
        destStart: usize,
        sourceRange: Range,
    };

    var mapData = std.ArrayList(TransformRange).init(allocator);
    while (maps.next()) |map| {
        mapData.clearRetainingCapacity();
        var lines = std.mem.tokenizeScalar(u8, map, '\n');
        _ = lines.next();
        while (lines.next()) |line| {
            var numbers = std.mem.tokenizeScalar(u8, line, ' ');
            const destStart = try std.fmt.parseInt(usize, numbers.next().?, 10);
            const sourceStart = try std.fmt.parseInt(usize, numbers.next().?, 10);
            const length = try std.fmt.parseInt(usize, numbers.next().?, 10);
            const sourceRange = Range{ .start = sourceStart, .end = sourceStart + length };
            try mapData.append(.{ .destStart = destStart, .sourceRange = sourceRange });
        }

        var i: usize = 0;
        while (i < result.items.len) : (i += 1) {
            const source = result.items[i];
            for (mapData.items) |transform| {
                const intersectionResult = getIntersection(source, transform.sourceRange);
                if (intersectionResult.intersection) |intersection| {
                    const offset = intersection.start - transform.sourceRange.start;
                    result.items[i] = Range{
                        .start = transform.destStart + offset,
                        .end = transform.destStart + offset + (intersection.end - intersection.start),
                    };
                    if (intersectionResult.left) |left| {
                        try result.append(left);
                    }
                    if (intersectionResult.right) |right| {
                        try result.append(right);
                    }
                    break;
                }
            }
        }
    }

    var minLocation: usize = std.math.maxInt(usize);
    for (result.items) |range| {
        if (range.start < minLocation) {
            minLocation = range.start;
        }
    }

    std.debug.print("Result: {}\n", .{minLocation});
}

const IntersectionResult = struct {
    intersection: ?Range,
    left: ?Range = null,
    right: ?Range = null,
};

fn getIntersection(source: Range, target: Range) IntersectionResult {
    if (source.end <= target.start or source.start >= target.end) {
        return .{ .intersection = null };
    }

    const interStart = max(source.start, target.start);
    const interEnd = min(source.end, target.end);
    const intersection = Range{ .start = interStart, .end = interEnd };

    var result = IntersectionResult{ .intersection = intersection };

    if (interStart > source.start) {
        result.left = Range{ .start = source.start, .end = interStart };
    }
    if (interEnd < source.end) {
        result.right = Range{ .start = interEnd, .end = source.end };
    }

    return result;
}

fn min(a: usize, b: usize) usize {
    return if (a < b) a else b;
}

fn max(a: usize, b: usize) usize {
    return if (a > b) a else b;
}
