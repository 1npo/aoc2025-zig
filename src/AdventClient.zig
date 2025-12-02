const std = @import("std");
const Client = std.http.Client;
const Status = std.http.Status;
const utils = @import("utils.zig");

const AdventClient = @This();

allocator: std.mem.Allocator,
client: Client,
user_agent: []const u8 = "aoc2025-zig <http://github.com/1npo/aoc2025-zig>",
session_token: []const u8 = undefined,
cache_dir: ?[]const u8 = null,

pub fn init(advent_client: *AdventClient) !void {
    const token = try advent_client.getSessionToken();
    advent_client.session_token = try std.fmt.allocPrint(
        advent_client.allocator,
        "session={s}",
        .{token},
    );
    advent_client.setupCacheDir() catch {};
}

fn getSessionToken(advent_client: *AdventClient) ![]u8 {
    const session_token = std.process.getEnvVarOwned(
        advent_client.allocator,
        "AOC_SESSION_TOKEN",
    ) catch |err| {
        std.debug.print(
            "Unable to get AOC_SESSION_TOKEN from the environment: {s}\n",
            .{@errorName(err)},
        );
        std.debug.print(
            "A session token is required to use AdventClient. Please get your session " ++
                "token and save it to the AOC_SESSION_TOKEN environment variable, " ++
                "then try again.",
            .{},
        );
        std.process.exit(1);
    };

    std.debug.print("Using AOC_SESSION_TOKEN={s}\n", .{session_token});
    return session_token;
}

fn setupCacheDir(advent_client: *AdventClient) !void {
    const cache_dir = std.process.getEnvVarOwned(
        advent_client.allocator,
        "XDG_CACHE_HOME",
    ) catch |err| {
        std.debug.print(
            "Unable to get XDG_CACHE_HOME from the environment: {s}\n",
            .{@errorName(err)},
        );
        return err;
    };
    if (std.fs.path.isAbsolute(cache_dir)) {
        advent_client.cache_dir = try std.fmt.allocPrint(
            advent_client.allocator,
            "{s}/aoc2025-zig",
            .{cache_dir},
        );
        try std.fs.makeDirAbsolute(advent_client.cache_dir.?);
    }
}

fn cachePuzzleInput(advent_client: *AdventClient, file_name: []const u8, input: []const u8) !void {
    const dir = try std.fs.openDirAbsolute(advent_client.cache_dir.?, .{});
    const file = try dir.createFile(file_name, .{});
    defer file.close();
    try file.writeAll(input);
}

fn getCachedInput(advent_client: *AdventClient, file_name: []const u8) !?[]u8 {
    const dir = try std.fs.openDirAbsolute(advent_client.cache_dir.?, .{});
    const file = dir.openFile(file_name, .{}) catch |err| {
        std.debug.print("Unable to get cached file '{s}': {s}\n", .{
            file_name,
            @errorName(err),
        });
        return null;
    };
    defer file.close();

    const file_stat = try file.stat();
    const file_size = file_stat.size;
    const content = try file.readToEndAlloc(advent_client.allocator, file_size);
    return content;
}

fn sendRequest(advent_client: *AdventClient, options: Client.FetchOptions) !?[]u8 {
    var body: std.Io.Writer.Allocating = .init(advent_client.allocator);
    defer body.deinit();
    try body.ensureUnusedCapacity(64);

    const new_options = Client.FetchOptions{
        .location = options.location,
        .method = options.method,
        .headers = options.headers,
        .extra_headers = options.extra_headers,
        .response_writer = &body.writer,
    };
    const res = try advent_client.client.fetch(new_options);

    if (res.status.class() != Status.Class.success) {
        std.debug.print(
            "Failed to send request to adventofcode.com: status: {s}\n",
            .{res.status.phrase().?},
        );
        return null;
    }

    const input = try advent_client.allocator.dupe(u8, body.written());
    return input;
}

pub fn getPuzzleInput(advent_client: *AdventClient, year: u16, day: u8) !?[]u8 {
    const file_name = try std.fmt.allocPrint(
        advent_client.allocator,
        "{d}_{d}.txt",
        .{ year, day },
    );

    var input: ?[]u8 = null;

    if (advent_client.cache_dir != null) {
        std.debug.print("Trying to get puzzle input from cache...\n", .{});
        input = try advent_client.getCachedInput(file_name);
        if (input != null) {
            std.debug.print("Got cached puzzle input.\n", .{});
            return input;
        }
    }

    const url = try std.fmt.allocPrint(
        advent_client.allocator,
        "https://adventofcode.com/{}/day/{}/input",
        .{ year, day },
    );
    defer advent_client.allocator.free(url);

    std.debug.print("Trying to fetch puzzle input from adventofcode.com...\n", .{});
    input = try advent_client.sendRequest(.{
        .location = .{ .url = url },
        .method = .GET,
        .headers = .{ .user_agent = .{ .override = advent_client.user_agent } },
        .extra_headers = &.{.{ .name = "cookie", .value = advent_client.session_token }},
    });

    if (input != null) {
        if (advent_client.cache_dir != null) {
            std.debug.print("Caching puzzle input...\n", .{});
            try advent_client.cachePuzzleInput(file_name, input.?);
        }
    }
    return input;
}

pub fn submitPuzzleAnswer(advent_client: *AdventClient, year: u16, day: u8, part: u8) !bool {
    _ = advent_client;
    _ = year;
    _ = day;
    _ = part;
}
