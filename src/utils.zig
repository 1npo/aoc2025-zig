const std = @import("std");

pub fn dirExists(path: []const u8) !bool {
    const dir = std.fs.openDirAbsolute(path, .{}) catch |err| switch (err) {
        error.FileNotFound => return false,
        else => return false,
    };
    defer dir.close();
    return true;
}

const Duration = struct {
    total_ns: i128,
    hours: i128,
    minutes: i128,
    seconds: i128,
    milliseconds: i128,
    nanoseconds: i128,

    pub fn printDuration(self: Duration, allocator: std.mem.Allocator) ![]u8 {
        return try std.fmt.allocPrint(allocator, "{d}h {d}m {d}s {d}ms {d}ns", .{
            self.hours,
            self.minutes,
            self.seconds,
            self.milliseconds,
            self.nanoseconds,
        });
    }
};

pub fn nsToDuration(total_ns: i128) Duration {
    const ns_per_ms = 1_000_000;
    const ns_per_sec = 1_000_000_000;
    const ns_per_minute = 60 * ns_per_sec;
    const ns_per_hour = 60 * ns_per_minute;

    const remaining_ns_after_hours = @mod(total_ns, ns_per_hour);
    const remaining_ns_after_minutes = @mod(remaining_ns_after_hours, ns_per_minute);
    const remaining_ns_after_seconds = @mod(remaining_ns_after_minutes, ns_per_sec);

    return .{
        .total_ns = total_ns,
        .hours = @divTrunc(total_ns, ns_per_hour),
        .minutes = @divTrunc(remaining_ns_after_hours, ns_per_minute),
        .seconds = @divTrunc(remaining_ns_after_minutes, ns_per_sec),
        .milliseconds = @divTrunc(remaining_ns_after_seconds, ns_per_ms),
        .nanoseconds = @mod(remaining_ns_after_seconds, ns_per_ms),
    };
}

const FnPointer = fn (std.mem.Allocator, []const u8) anyerror!u128;

pub fn measureRuntime(function: FnPointer, allocator: std.mem.Allocator, input: []const u8) !Duration {
    const start = std.time.nanoTimestamp();
    _ = try function(allocator, input);
    const end = std.time.nanoTimestamp();
    return nsToDuration(end - start);
}
