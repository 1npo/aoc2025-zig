const std = @import("std");

const Part = enum { one, two };
const Operation = enum { add, multiply };
const MathProblem = struct {
    numbers: std.ArrayList(u64),
    operation: Operation = undefined,

    pub fn add(self: MathProblem) u64 {
        var result: u64 = 0;
        for (self.numbers.items) |num| {
            result += num;
        }
        return result;
    }

    pub fn multiply(self: MathProblem) u64 {
        var result: u64 = 1;
        for (self.numbers.items) |num| {
            result *= num;
        }
        return result;
    }
};
const MathProblemColumn = struct { width: u8, operation: Operation };

fn sum(numbers: []const i32) i32 {
    var result: i32 = 0;
    for (numbers) |x| {
        result += x;
    }
    return result;
}

fn getMathProblemsHumanNotation(
    allocator: std.mem.Allocator,
    input: []const u8,
) !std.ArrayList(MathProblem) {
    var split_input: std.ArrayList([][]const u8) = .empty;
    var math_problems: std.ArrayList(MathProblem) = .empty;
    var it = std.mem.splitSequence(u8, input, "\n");

    while (it.next()) |line| {
        if (line.len == 0) continue;
        const line_stripped = std.mem.trimRight(u8, line, "\r\n");
        const line_var: []u8 = try allocator.dupe(u8, line_stripped);
        var split_line: std.ArrayList([]const u8) = .empty;
        var it_line = std.mem.tokenizeScalar(u8, line_var, ' ');
        while (it_line.next()) |token| {
            try split_line.append(allocator, token);
            std.debug.print("token = {s}\n", .{token});
        }
        try split_input.append(allocator, split_line.items);
    }

    for (split_input.items) |line| {
        for (line, 0..) |token, token_idx| {
            if (math_problems.items.len < token_idx + 1) {
                const numbers: std.ArrayList(u64) = .empty;
                const problem = MathProblem{ .numbers = numbers };
                try math_problems.append(allocator, problem);
            }
            if (std.mem.eql(u8, token, "+")) {
                math_problems.items[token_idx].operation = .add;
            } else if (std.mem.eql(u8, token, "*")) {
                math_problems.items[token_idx].operation = .multiply;
            } else {
                const token_num = try std.fmt.parseInt(u64, token, 10);
                try math_problems.items[token_idx].numbers.append(allocator, token_num);
            }
        }
    }
    return math_problems;
}

// For celphalopod notation, instead of tokenizing each line using a space as the delimiter,
// we need to split each line in fixed width increments.
fn getMathProblemsCephalopodNotation(
    allocator: std.mem.Allocator,
    input: []const u8,
) !std.ArrayList(MathProblem) {
    var lines: std.ArrayList([]u8) = .empty;
    //var math_problems: std.ArrayList(MathProblem) = .empty;
    var it = std.mem.splitSequence(u8, input, "\n");

    while (it.next()) |line| {
        if (line.len == 0) continue;
        const line_stripped = std.mem.trimRight(u8, line, "\r\n");
        const line_var: []u8 = try allocator.dupe(u8, line_stripped);
        try lines.append(allocator, line_var);
    }

    // The operator on the last line is always in the leftmost column, so we can use the
    // line of operators to determine the width of each column.
    var columns: std.ArrayList(MathProblemColumn) = .empty;
    var columns_counter: u8 = 0;
    var column_cursor: u8 = 0;
    for (lines.items[lines.items.len - 1]) |char| {
        if (char == '+' or char == '*') {
            var column = MathProblemColumn{ .width = undefined, .operation = undefined };
            if (char == '+') {
                column.operation = .add;
            } else if (char == '*') {
                column.operation = .multiply;
            }
            try columns.append(allocator, column);

            // We're on the first column, so we can't get the width yet. We get the width
            // when we reach the next operator or the end of the line
            if (column_cursor == 0) {} else {
                columns.items[columns_counter - 1] = column_cursor - 1;
                column_cursor = 0;
            }
            columns_counter += 1;
        }
        column_cursor += 1;
    }

    return 0;
    //return math_problems;
}

fn solvePuzzle(allocator: std.mem.Allocator, input: []const u8, part: Part) !u128 {
    var grand_total: u128 = 0;
    var math_problems: std.ArrayList(MathProblem) = undefined;

    switch (part) {
        .one => {
            math_problems = try getMathProblemsHumanNotation(allocator, input);
        },
        .two => {
            return 0;
            //math_problems = try getMathProblemsCephalopodNotation(allocator, input);
        },
    }

    for (math_problems.items, 1..) |problem, num| {
        std.debug.print(
            "problem {d} -> {any} {any}\n",
            .{ num, problem.operation, problem.numbers.items },
        );
    }

    for (math_problems.items) |problem| {
        switch (problem.operation) {
            .add => {
                grand_total += problem.add();
            },
            .multiply => {
                grand_total += problem.multiply();
            },
        }
    }
    std.debug.print("grand_total = {d}\n", .{grand_total});
    return grand_total;
}

pub fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !u128 {
    const solution = try solvePuzzle(allocator, input, .one);
    return solution;
}

pub fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !u128 {
    const solution = try solvePuzzle(allocator, input, .two);
    return solution;
}
