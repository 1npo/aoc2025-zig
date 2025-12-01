const std = @import("std");

pub fn dirExists(path: []const u8) !bool {
    const dir = std.fs.openDirAbsolute(path, .{}) catch |err| switch (err) {
        error.FileNotFound => return false,
        else => return false,
    };
    defer dir.close();
    return true;
}
