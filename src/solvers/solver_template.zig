const std = @import("std");

const Part = enum { one, two };

fn solvePuzzle(allocator: std.mem.Allocator, input: []const u8, part: Part) !u128 {
    _ = allocator;
    _ = input;
    switch (part) {
        .one => {},
        .two => {},
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
