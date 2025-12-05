const std = @import("std");
const AdventClient = @import("AdventClient.zig");
const utils = @import("utils.zig");

const temp_solver = @import("solvers/solver_2025_4.zig");

// The user is required to provide the year and day of the puzzle to solve as the first
// and second CLI arguments. The program will exit if there was an issue getting a valid
// year and day from the user.
fn getYearAndDay(allocator: std.mem.Allocator) struct { u16, u8 } {
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.next();
    var index: u8 = 0;
    var year: ?u16 = null;
    var day: ?u8 = null;

    while (args.next()) |arg| {
        switch (index) {
            0 => {
                year = std.fmt.parseInt(u16, arg, 10) catch |err| switch (err) {
                    std.fmt.ParseIntError.InvalidCharacter => {
                        std.debug.print(
                            "Please specify a valid year. No year was given, or given" ++
                                "year number contained an unexpected character.\n",
                            .{},
                        );
                        std.process.exit(1);
                    },
                    std.fmt.ParseIntError.Overflow => {
                        std.debug.print(
                            "Please specify a valid year. Given year number was too" ++
                                "large.\n",
                            .{},
                        );
                        std.process.exit(1);
                    },
                };
            },
            1 => {
                day = std.fmt.parseInt(u8, arg, 10) catch |err| switch (err) {
                    std.fmt.ParseIntError.InvalidCharacter => {
                        std.debug.print(
                            "Please specify a valid day. No day was given, or given day" ++
                                "number contained an unexpected character.\n",
                            .{},
                        );
                        std.process.exit(1);
                    },
                    std.fmt.ParseIntError.Overflow => {
                        std.debug.print(
                            "Please specify a valid day. Given day number was too large.\n",
                            .{},
                        );
                        std.process.exit(1);
                    },
                };
            },
            else => break,
        }
        // std.debug.print("arg #{d} = {s}\n", .{ index, arg });
        index += 1;
    }
    if (year == null) {
        std.debug.print(
            "No year was given. Please specify the year and day as the first and" ++
                "second CLI arguments, respectively.\n",
            .{},
        );
        std.process.exit(1);
    }
    if (day == null) {
        std.debug.print(
            "No day was given. Please specify the year and day as the first and second" ++
                "CLI arguments, respectively.\n",
            .{},
        );
        std.process.exit(1);
    }
    return .{ year.?, day.? };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var year: u16 = undefined;
    var day: u8 = undefined;

    // The program will exit before getYearAndDay returns if there was an issue getting
    // the year and/or day from the user, otherwise `getYearAndDay` is guaranteed to
    // return a .{ year: u16, day: u8 }
    year, day = getYearAndDay(allocator);

    var client: std.http.Client = .{ .allocator = allocator };
    defer client.deinit();

    var advent_client: AdventClient = .{ .allocator = allocator, .client = client };
    try advent_client.init();

    var input: ?[]u8 = null;
    input = try advent_client.getPuzzleInput(year, day);
    if (input == null) {
        std.debug.print("Unable to solve puzzle without puzzle input. Quitting.", .{});
        std.process.exit(1);
    }

    std.debug.print("input={s}\n", .{input.?});
    std.debug.print("cache_dir={s}\n", .{advent_client.cache_dir orelse ""});

    // TODO: Implement a dynamic solver
    // _ = try temp_solver.solvePart1(allocator, input.?);
    // _ = try temp_solver.solvePart2(allocator, input.?);
    const part1_duration = try utils.measureRuntime(temp_solver.solvePart1, allocator, input.?);
    const part2_duration = try utils.measureRuntime(temp_solver.solvePart2, allocator, input.?);

    const part1_time = try part1_duration.printDuration(allocator);
    const part2_time = try part2_duration.printDuration(allocator);

    std.debug.print("Got part 1 answer in {s}\n", .{part1_time});
    std.debug.print("Got part 2 answer in {s}\n", .{part2_time});
}
