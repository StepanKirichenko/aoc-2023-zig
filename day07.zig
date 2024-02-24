const std = @import("std");

const HandType = enum {
    high_card,
    one_pair,
    two_pair,
    three,
    full_house,
    four,
    five,
};

const Hand = struct {
    cards: []const u8,
    type: HandType,
    bid: usize,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const file = try std.fs.cwd().openFile("input/day07.txt", .{});
    defer file.close();
    const stat = try file.stat();
    const input = try file.readToEndAlloc(allocator, stat.size);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var hands1 = std.ArrayList(Hand).init(allocator);
    defer hands1.deinit();

    var hands2 = std.ArrayList(Hand).init(allocator);
    defer hands2.deinit();

    while (lines.next()) |line| {
        var words = std.mem.tokenizeScalar(u8, line, ' ');

        const cards_str = words.next().?;
        const bid_str = words.next().?;

        const bid = try std.fmt.parseInt(usize, bid_str, 10);

        const hand = Hand{
            .cards = cards_str,
            .type = getHandType(cards_str, null),
            .bid = bid,
        };

        const hand2 = Hand{
            .cards = cards_str,
            .type = getHandType(cards_str, 'J'),
            .bid = bid,
        };

        try hands1.append(hand);
        try hands2.append(hand2);
    }

    std.sort.insertion(Hand, hands1.items, {}, lessThanHands1);
    std.sort.insertion(Hand, hands2.items, {}, lessThanHands2);

    var total: usize = 0;
    var total2: usize = 0;
    for (hands1.items, hands2.items, 1..) |hand, hand2, rank| {
        total += rank * hand.bid;
        total2 += rank * hand2.bid;
    }

    std.debug.print("Part 1: {}\n", .{total});
    std.debug.print("Part 2: {}\n", .{total2});
}

fn getHandType(cards: []const u8, joker_card: ?u8) HandType {
    var sorted: [5]u8 = undefined;
    @memcpy(&sorted, cards);
    std.sort.insertion(u8, &sorted, {}, std.sort.asc(u8));
    var pair_count: usize = 0;
    var max: usize = 1;
    var current: usize = 1;
    var jokers: usize = 0;

    const has_jokers = joker_card != null;
    const joker = joker_card orelse 0;

    if (has_jokers and sorted[0] == joker) {
        jokers += 1;
    }

    for (sorted[1..5], sorted[0..4]) |card, prev_card| {
        if (has_jokers and card == joker) {
            jokers += 1;
            continue;
        }

        if (card != prev_card) {
            current = 1;
            continue;
        }

        current += 1;

        if (current > max) {
            max = current;
        }
        if (current == 2) {
            pair_count += 1;
        }
    }

    if (jokers == 5) {
        return .five;
    }

    max += jokers;

    return switch (max) {
        5 => .five,
        4 => .four,
        3 => if (pair_count > 1) .full_house else .three,
        2 => if (pair_count > 1) .two_pair else .one_pair,
        1 => .high_card,
        else => unreachable,
    };
}

fn lessThanCards(a: u8, b: u8, order: []const u8) bool {
    if (a == b) {
        return false;
    }

    const a_i = std.mem.indexOfScalar(u8, order, a).?;
    const b_i = std.mem.indexOfScalar(u8, order, b).?;

    return a_i < b_i;
}

const order1 = [_]u8{ '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A' };
const order2 = [_]u8{ 'J', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A' };

fn lessThanCards1(a: u8, b: u8) bool {
    return lessThanCards(a, b, &order1);
}

fn lessThanCards2(a: u8, b: u8) bool {
    return lessThanCards(a, b, &order2);
}

fn lessThanHands(a: Hand, b: Hand, comptime lessThan: fn (u8, u8) bool) bool {
    if (a.type != b.type) {
        return @intFromEnum(a.type) < @intFromEnum(b.type);
    }

    for (a.cards, b.cards) |a_card, b_card| {
        if (a_card != b_card) {
            return lessThan(a_card, b_card);
        }
    }

    return false;
}

fn lessThanHands1(_: void, a: Hand, b: Hand) bool {
    return lessThanHands(a, b, lessThanCards1);
}

fn lessThanHands2(_: void, a: Hand, b: Hand) bool {
    return lessThanHands(a, b, lessThanCards2);
}
