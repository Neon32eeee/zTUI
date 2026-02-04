const std = @import("std");

pub const Input = struct {
    stdin: std.fs.File.Reader,

    const Self = @This();

    pub fn init(buffer: []u8) Self {
        return Self{ .stdin = std.fs.File.stdin().reader(buffer[0..]) };
    }

    pub fn hearing(self: *Self) ![]const u8 {
        const input = try self.stdin.interface.takeDelimiterExclusive('\n');

        if (input.len != 0) {
            return std.mem.trimRight(u8, input, "\r\n");
        } else {
            return "";
        }
    }
};
