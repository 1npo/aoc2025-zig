const std = @import("std");

const Part = enum { one, two };
const Solution = struct { fresh_ingredients: u128, fresh_ingredients_all: u128 };
const Range = struct { usize, usize };
const DatabaseFile = struct {
    ranges: std.ArrayList(Range),
    ingredients: std.ArrayList(u128),
};

fn getDatabaseFile(allocator: std.mem.Allocator, input: []const u8) !DatabaseFile {
    var it = std.mem.splitSequence(u8, input, "\n");
    var ranges: std.ArrayList(Range) = .empty;
    var ingredients: std.ArrayList(u128) = .empty;

    while (it.next()) |line| {
        if (line.len == 0) continue;
        const line_stripped = std.mem.trimRight(u8, line, "\r\n");
        const line_var: []u8 = try allocator.dupe(u8, line_stripped);

        if (std.mem.containsAtLeastScalar(u8, line_var, 1, '-')) {
            var line_it = std.mem.splitSequence(u8, line_var, "-");
            const start = try std.fmt.parseInt(usize, line_it.next().?, 10);
            const end = try std.fmt.parseInt(usize, line_it.next().?, 10);
            try ranges.append(allocator, .{ start, end });
            std.debug.print("Got range: {d} - {d}\n", .{ start, end });
        } else {
            const line_var_num = try std.fmt.parseInt(u128, line_var, 10);
            try ingredients.append(allocator, line_var_num);
            std.debug.print("Got ingredient: {d}\n", .{line_var_num});
        }
    }

    return .{ .ranges = ranges, .ingredients = ingredients };
}

fn compareRanges(context: void, a: Range, b: Range) bool {
    _ = context;
    return a[0] < b[0];
}

fn solvePuzzle(allocator: std.mem.Allocator, input: []const u8, part: Part) !u128 {
    const database: DatabaseFile = try getDatabaseFile(allocator, input);

    switch (part) {
        .one => {
            var fresh_ingredients: u128 = 0;
            outer: for (database.ingredients.items) |ingredient| {
                for (database.ranges.items) |range| {
                    if (range[0] <= ingredient and ingredient <= range[1]) {
                        fresh_ingredients += 1;
                        continue :outer;
                    }
                }
            }
            std.debug.print("Fresh ingredients = {d}\n", .{fresh_ingredients});
            return fresh_ingredients;
        },
        .two => {
            std.mem.sort(Range, database.ranges.items, {}, compareRanges);

            var current_start: usize = database.ranges.items[0][0];
            var current_end: usize = database.ranges.items[0][1];
            var merged_ranges: std.ArrayList(Range) = .empty;
            var fresh_ingredients_all: u128 = 0;

            for (database.ranges.items[1..]) |range| {
                const start = range[0];
                const end = range[1];
                if (start <= current_end + 1) {
                    current_end = @max(current_end, end);
                } else {
                    try merged_ranges.append(allocator, .{ current_start, current_end });
                    current_start = start;
                    current_end = end;
                }
            }
            try merged_ranges.append(allocator, .{ current_start, current_end });

            for (merged_ranges.items) |range| {
                fresh_ingredients_all += range[1] - range[0] + 1;
            }
            std.debug.print("Fresh ingredients = {d}\n", .{fresh_ingredients_all});
            return fresh_ingredients_all;
        },
    }
}

pub fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !u128 {
    const solution = try solvePuzzle(allocator, input, .one);
    return solution;
}

pub fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !u128 {
    const solution = try solvePuzzle(allocator, input, .two);
    return solution;
}
