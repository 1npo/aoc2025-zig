const std = @import("std");

const Safe = struct {
    dial: [100]u8 = undefined,
    dial_arrow: usize = undefined,
    password: i16 = undefined,

    pub fn init() Safe {
        var dial: [100]u8 = undefined;
        for (0..100) |i| {
            dial[i] = @intCast(i);
        }
        return .{
            .dial = dial,
            .dial_arrow = 50,
            .password = 0,
        };
    }

    pub fn rotateRight(self: *Safe, clicks: isize) void {
        const tmp_arrow: isize = @intCast(self.dial_arrow);
        const new_arrow = @mod(@mod(tmp_arrow + clicks, 100) + 100, 100);
        self.dial_arrow = @intCast(new_arrow);
    }

    pub fn rotateLeft(self: *Safe, clicks: isize) void {
        const tmp_arrow: isize = @intCast(self.dial_arrow);
        const new_arrow = @mod(@mod(tmp_arrow - clicks, 100) + 100, 100);
        self.dial_arrow = @intCast(new_arrow);
    }

    pub fn rotateRightWithWrap(self: *Safe, clicks: isize) void {
        const tmp_arrow: isize = @intCast(self.dial_arrow);
        const absolute_end = tmp_arrow + clicks;
        const wrap_count = @divFloor(absolute_end, 100) - @divFloor(tmp_arrow, 100);
        const new_arrow = @mod(@mod(absolute_end, 100) + 100, 100);
        self.dial_arrow = @intCast(new_arrow);
        // if (new_arrow == 0) {
        //     wrap_count += 1;
        // }
        if (wrap_count > 0) {
            self.password += @intCast(wrap_count);
        }
        std.debug.print("wrapped {d} times when rotating right\n", .{wrap_count});
    }

    pub fn rotateLeftWithWrap(self: *Safe, clicks: isize) void {
        const tmp_arrow: isize = @intCast(self.dial_arrow);
        const absolute_end = tmp_arrow - clicks;
        const wrap_count = @divFloor(tmp_arrow, 100) - @divFloor(absolute_end, 100);
        const new_arrow = @mod(@mod(absolute_end, 100) + 100, 100);
        self.dial_arrow = @intCast(new_arrow);
        // if (new_arrow == 0) {
        //     wrap_count += 1;
        // }
        if (wrap_count > 0) {
            self.password += @intCast(wrap_count);
        }
        std.debug.print("wrapped {d} times when rotating left\n", .{wrap_count});
    }
};

pub fn solve_part_1(input: []const u8) !u16 {
    var safe = Safe.init();
    std.debug.print("initial position of dial_arrow = {d}\n", .{safe.dial_arrow});

    var it = std.mem.splitSequence(u8, input, "\n");
    var password: u16 = 0;

    while (it.next()) |line_slice| {
        if (line_slice.len == 0) continue;

        const direction: u8 = line_slice[0];
        const clicks: isize = try std.fmt.parseInt(isize, line_slice[1..], 10);

        if (direction == 'R') {
            safe.rotateRight(clicks);
        } else if (direction == 'L') {
            safe.rotateLeft(clicks);
        }

        if (safe.dial_arrow == 0) {
            password += 1;
        }
    }

    std.debug.print("password is {d}\n", .{password});
    return password;
}

pub fn solve_part_2(input: []const u8) !u16 {
    var safe = Safe.init();
    std.debug.print("initial position of dial_arrow = {d}\n", .{safe.dial_arrow});

    var it = std.mem.splitSequence(u8, input, "\n");

    while (it.next()) |line_slice| {
        if (line_slice.len == 0) continue;

        const direction: u8 = line_slice[0];
        const clicks: isize = try std.fmt.parseInt(isize, line_slice[1..], 10);

        std.debug.print(
            "dial pointing at {d} ; rotating dial {d} clicks {c}\n",
            .{ safe.dial_arrow, clicks, direction },
        );

        if (direction == 'R') {
            safe.rotateRightWithWrap(clicks);
        } else if (direction == 'L') {
            safe.rotateLeftWithWrap(clicks);
        }

        std.debug.print(
            "dial now pointing at {d} ; password is {d}\n",
            .{ safe.dial_arrow, safe.password },
        );

        // password += safe.password;
        // if (safe.dial_arrow == 0) {
        //     password += 1;
        // }
    }

    std.debug.print("password is {d}\n", .{safe.password});
    return @intCast(safe.password);
}
