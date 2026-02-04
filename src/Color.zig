const std = @import("std");

pub const ColorName = enum {
    none,
    red,
    green,
    yellow,
    blue,
};

const ColorsCode = struct {
    pub const red: []const u8 = "\x1b[31m";
    pub const green: []const u8 = "\x1b[32m";
    pub const yellow: []const u8 = "\x1b[33m";
    pub const blue: []const u8 = "\x1b[34m";
};

pub fn colorize(t: *std.ArrayList([]const u8), c: ColorName, allocator: std.mem.Allocator) !std.ArrayList([]const u8) {
    defer {
        for (t.items) |line| {
            allocator.free(line);
        }
        _ = t.deinit(allocator);
    }

    const color_code = switch (c) {
        ColorName.none => "\x1b[0m",
        ColorName.red => ColorsCode.red,
        ColorName.green => ColorsCode.green,
        ColorName.yellow => ColorsCode.yellow,
        ColorName.blue => ColorsCode.blue,
    };

    var colorize_return_text = std.ArrayList([]const u8){};

    if (t.items.len > 1) {
        const new_first = try std.mem.concat(allocator, u8, &[_][]const u8{ color_code, t.items[0] });
        try colorize_return_text.append(allocator, new_first);
        if (t.items.len == 2) {
            const new_last = try std.mem.concat(allocator, u8, &[_][]const u8{ t.items[1], "\x1b[0m" });
            try colorize_return_text.append(allocator, new_last);
        } else {
            for (1..t.items.len - 2) |i| {
                const original_slice = t.items[i];
                const new_middle = try allocator.alloc(u8, original_slice.len);
                @memcpy(new_middle, original_slice);
                try colorize_return_text.append(allocator, new_middle);
            }
            const new_last = try std.mem.concat(allocator, u8, &[_][]const u8{ t.items[t.items.len - 1], "\x1b[0m" });
            try colorize_return_text.append(allocator, new_last);
        }
    } else {
        const new_first = try std.mem.concat(allocator, u8, &[_][]const u8{ color_code, t.items[0], "\x1b[0m" });
        try colorize_return_text.append(allocator, new_first);
    }

    return colorize_return_text;
}

pub fn colorize_text(t: []const u8, c: ColorName, allocator: std.mem.Allocator) ![]const u8 {
    const color_code = switch (c) {
        ColorName.none => "\x1b[0m",
        ColorName.red => ColorsCode.red,
        ColorName.green => ColorsCode.green,
        ColorName.yellow => ColorsCode.yellow,
        ColorName.blue => ColorsCode.blue,
    };

    const colorize_return_text = try std.mem.concat(allocator, u8, &[_][]const u8{ color_code, t, "\x1b[0m" });

    return colorize_return_text;
}
