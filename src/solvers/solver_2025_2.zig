const std = @import("std");

const Part = enum { one, two };

fn idIsPairOfEqualSequences(allocator: std.mem.Allocator, id: u64) !?u64 {
    const id_string = try std.fmt.allocPrint(allocator, "{d}", .{id});
    if (id_string[0] == '0') return null;
    if (id_string.len % 2 != 0) return null;
    const first = id_string[0 .. id_string.len / 2];
    const last = id_string[id_string.len / 2 ..];
    if (std.mem.eql(u8, first, last)) return id;
    return null;
}

fn idIsSequenceRepeatedAtLeastTwice(allocator: std.mem.Allocator, id: u64) !?u64 {
    const id_string = try std.fmt.allocPrint(allocator, "{d}", .{id});
    const id_string_len = id_string.len;
    if (id_string[0] == '0') return null;
    for (1..id_string_len / 2 + 1) |seq_size| {
        if (id_string_len % seq_size != 0) continue;
        if (id_string_len / seq_size < 2) continue;
        var ok = true;
        var i: usize = seq_size;
        while (i < id_string_len) : (i += seq_size) {
            if (!std.mem.eql(u8, id_string[0..seq_size], id_string[i .. i + seq_size])) {
                ok = false;
                break;
            }
        }
        if (ok) return id;
    }
    return null;
}

fn solvePuzzle(allocator: std.mem.Allocator, input: []const u8, part: Part) !u128 {
    // 1. Split the string on commas to get the ID ranges
    // 2. For each range, split the string on hyphens to get the start and end of the range
    // 3. Cast the start and end strings as i64s
    // 4. For each number in the range between the start and end, get the result of
    //  isIdInvalid() on that number
    // 5. If the result is true, increment the invalid_ids counter
    var it = std.mem.splitSequence(u8, input, ",");
    var invalid_id_sum: u128 = 0;
    while (it.next()) |range| {
        if (range.len == 0) continue;
        const stripped_range = std.mem.trimRight(u8, range, "\r\n");
        var it_range = std.mem.splitSequence(u8, stripped_range, "-");
        const start = try std.fmt.parseInt(usize, it_range.next().?, 10);
        const end = try std.fmt.parseInt(usize, it_range.next().?, 10);
        var checked_id: ?u64 = null;
        for (start..end) |num| {
            switch (part) {
                .one => checked_id = try idIsPairOfEqualSequences(allocator, num),
                .two => checked_id = try idIsSequenceRepeatedAtLeastTwice(allocator, num),
            }
            if (checked_id == null) continue;
            invalid_id_sum += @intCast(checked_id.?);
        }
    }
    std.debug.print("sum of invalid IDs = {d}\n", .{invalid_id_sum});
    return invalid_id_sum;
}

pub fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !u128 {
    return solvePuzzle(allocator, input, .one);
}

pub fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !u128 {
    return solvePuzzle(allocator, input, .two);
}
