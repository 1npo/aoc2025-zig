const std = @import("std");

const Part = enum { one, two };
const Solution = struct { accessible_rolls: u128, input_new: []const u8 };

fn isRollForkliftAccessible(
    diagram: *std.ArrayList([]u8),
    row_i: usize,
    col_i: usize,
    remove: bool,
) bool {
    const check = [8][2]isize{
        [_]isize{ -1, -1 },
        [_]isize{ -1, 0 },
        [_]isize{ -1, 1 },
        [_]isize{ 0, 1 },
        [_]isize{ 1, 1 },
        [_]isize{ 1, 0 },
        [_]isize{ 1, -1 },
        [_]isize{ 0, -1 },
    };
    var adjacent_rolls: u8 = 0;
    for (check) |pair| {
        const peek_x: isize = pair[0];
        const peek_y: isize = pair[1];
        if (row_i == 0 and peek_x == -1) continue;
        if (col_i == 0 and peek_y == -1) continue;
        if (row_i == diagram.items.len - 1 and peek_x == 1) continue;
        if (col_i == diagram.items[row_i].len - 1 and peek_y == 1) continue;
        const row_i_i: isize = @intCast(row_i);
        const col_i_i: isize = @intCast(col_i);
        const x: usize = @intCast(peek_x + row_i_i);
        const y: usize = @intCast(peek_y + col_i_i);
        if (diagram.items[x][y] == '@') {
            adjacent_rolls += 1;
        }
    }
    if (adjacent_rolls < 4) {
        if (remove == true) {
            //std.debug.print(
            //    "[{d}][{d}] -> BEFORE = {c}\n",
            //    .{ row_i, col_i, diagram.items[row_i][col_i] },
            //);
            diagram.items[row_i][col_i] = 'x';
            //std.debug.print(
            //    "[{d}][{d}] -> AFTER = {c}\n",
            //    .{ row_i, col_i, diagram.items[row_i][col_i] },
            //);
        }
        return true;
    }
    return false;
}

fn solvePuzzle(allocator: std.mem.Allocator, input: []const u8, part: Part) !Solution {
    var it = std.mem.splitSequence(u8, input, "\n");
    var diagram: std.ArrayList([]u8) = .empty;
    var diagram_new: std.ArrayList([]u8) = .empty;
    var accessible_rolls: u128 = 0;

    var remove_rolls: bool = undefined;
    if (part == .one) {
        remove_rolls = false;
    } else {
        remove_rolls = true;
    }

    while (it.next()) |line| {
        if (line.len == 0) continue;
        const line_stripped = std.mem.trimRight(u8, line, "\r\n");
        const line_var: []u8 = try allocator.dupe(u8, line_stripped);
        try diagram.append(allocator, line_var);
    }

    for (diagram.items, 0..) |row, row_i| {
        for (row, 0..) |cell, col_i| {
            if (cell != '@') continue;
            if (isRollForkliftAccessible(
                &diagram,
                @intCast(row_i),
                @intCast(col_i),
                remove_rolls,
            )) {
                accessible_rolls += 1;
            }
        }
        try diagram_new.append(allocator, diagram.items[row_i]);
    }
    std.debug.print("Accessible rolls = {d}\n", .{accessible_rolls});
    return .{
        .accessible_rolls = accessible_rolls,
        .input_new = try std.mem.join(allocator, "\n", diagram.items),
    };
}

pub fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !u128 {
    const solution = try solvePuzzle(allocator, input, .one);
    return solution.accessible_rolls;
}

pub fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !u128 {
    var rolls_removed: u128 = 0;
    var got_last_roll: bool = false;
    var input_new = input;

    while (!got_last_roll) {
        const solution = try solvePuzzle(allocator, input_new, .two);
        input_new = solution.input_new;
        rolls_removed += solution.accessible_rolls;
        if (solution.accessible_rolls == 0) {
            got_last_roll = true;
        }
    }
    std.debug.print("Total rolls removed = {d}\n", .{rolls_removed});
    return rolls_removed;
}
