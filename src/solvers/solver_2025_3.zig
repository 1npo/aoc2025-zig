const std = @import("std");

const Part = enum { one, two };

fn largestTwoNonConsecutiveDigits(line: []const u8) u128 {
    var max_number: i16 = -1;
    var max_first_digit: i16 = @intCast(line[0]);

    for (2..line.len) |i| {
        const current_digit: i16 = @intCast(line[i]);
        const current_number: i16 = max_first_digit * 10 + current_digit;
        if (current_number > max_number) {
            max_number = current_number;
        }
        const prev_digit: i16 = @intCast(line[i - 1]);
        if (prev_digit > max_first_digit) {
            max_first_digit = prev_digit;
        }
    }
    return @intCast(max_number);
}

fn largestXNoneConsecutiveDigits(line: []const u8) ![]u8 {
    return line;
}

fn solvePuzzle(allocator: std.mem.Allocator, input: []const u8, part: Part) !u128 {
    // 5. If the result is true, increment the invalid_ids counter
    _ = allocator;
    _ = part;
    var it = std.mem.splitSequence(u8, input, ",");
    var joltage: u128 = 0;
    while (it.next()) |bank| {
        if (bank.len == 0) continue;
        const bank_stripped = std.mem.trimRight(u8, bank, "\r\n");
        const bank_joltage: u128 = largestTwoNonConsecutiveDigits(bank_stripped);
        joltage += bank_joltage;
    }
    std.debug.print("Joltage = {d}\n", .{joltage});
    return joltage;
}

pub fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !u128 {
    return solvePuzzle(allocator, input, .one);
}

pub fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !u128 {
    return solvePuzzle(allocator, input, .two);
}
