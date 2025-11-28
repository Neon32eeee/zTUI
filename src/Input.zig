const std = @import("std");

pub const Input = struct {
    stdin: std.io.AnyReader,

    const Self = @This();

    pub fn init() Self {
        return Self{ .stdin = std.io.getStdIn().reader().any() };
    }

    pub fn hearing(self: Self, buffer: []u8) ![]const u8 {
        const input = try self.stdin.readUntilDelimiterOrEof(buffer, '\n');

        if (input) |line| {
            return std.mem.trimRight(u8, line, "\r\n");
        } else {
            return "";
        }
    }
};
