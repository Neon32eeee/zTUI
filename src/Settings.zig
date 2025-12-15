const std = @import("std");
const Color = @import("Color.zig");

pub const TUISettings = struct {
    w: usize = 90,
    h: usize = 10,
    name: []const u8 = "zTUI",
};

pub const InputSettings = struct { prompt: []const u8, color_promt: Color.ColorName = .none };

pub const ColorSettings = struct { color: Color.ColorName = .none };

pub const RowSettings = struct { color: Color.ColorName = .none, indentation: usize = 0 };

pub const ClearSettings = struct { index: ?usize = null};