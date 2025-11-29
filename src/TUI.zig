const std = @import("std");
const Input = @import("Input.zig");
const Word = @import("Word.zig");

pub const TUISettings = struct {
    w: usize = 90,
    h: usize = 10,
    name: []const u8 = "zTUI",
};

const InputSettings = struct { promt: []const u8 };

pub const TUI = struct {
    w: usize,
    h: usize,
    name: []const u8,
    enablve_input: bool,
    allocator: std.mem.Allocator,

    rows: std.ArrayList(std.ArrayList([]const u8)),

    promt: []const u8,
    input_enty: Input.Input = Input.Input.init(),

    const Self = @This();

    pub fn init(setting: TUISettings, allocator: std.mem.Allocator) !Self {
        if (setting.w >= 155) return error.InvalidWethg;
        if (setting.w <= 0) return error.InvalidWethg;

        const rows = std.ArrayList(std.ArrayList([]const u8)).init(allocator);

        const self = Self{ .w = setting.w, .h = setting.h, .name = setting.name, .enablve_input = false, .rows = rows, .promt = "", .allocator = allocator};

        return self;
    }

    pub fn deinit(self: *Self) void {
        const allocator = self.rows.allocator; 

        for (self.rows.items) |row_list| {
            for (row_list.items) |line| {
                allocator.free(line); 
            }

            row_list.deinit();
        }
    
        self.rows.deinit();
    }

    pub fn input_init(self: *Self, setting: InputSettings) void {
        self.enablve_input = true;

        self.promt = setting.promt;
    }

    pub fn hearing(self: *const Self, buffer: []u8) ![]const u8 {
        const result = try self.input_enty.hearing(buffer);

        if (result.len == 0) {
            return "";
        }

        return result;
    }

    pub fn append_row(self: *Self, row: []const u8) !void {
        const text = try Word.wrapText(self.w - 2, row, self.allocator);

        try self.rows.append(text);
    }

    fn displayWidth(slice: []const u8) usize {
        var width: usize = 0;
        var i: usize = 0;
        while (i < slice.len) : (i += std.unicode.utf8ByteSequenceLength(slice[i]) catch break) {
            width += 1;
        }
        return width;
}

    pub fn draw(self: *const Self) void {
        std.debug.print("z\x1B[2J\x1B[3J\x1B[H", .{});

        std.debug.print("╭", .{});
        for (0..(self.w - 2)) |_| {
            std.debug.print("─", .{});
        }
        std.debug.print("╮\n", .{});

        std.debug.print("│", .{});
        std.debug.print("{s}", .{self.name});
        for (0..(self.w - (2 + self.name.len))) |_| {
            std.debug.print(" ", .{});
        }
        std.debug.print("│\n", .{});

        var last_row_id: usize = 0;
        var last_line_id: usize = 0;
        for (0..(self.h - 1)) |_| {
            std.debug.print("│", .{});
            if (last_row_id < self.rows.items.len) {
                const row_list = self.rows.items[last_row_id];
                if (last_line_id < row_list.items.len) {
                    const print_line = row_list.items[last_line_id];
                    std.debug.print("{s}", .{print_line});
                   
                    const print_line_len = displayWidth(print_line);
                    if (print_line_len < self.w - 2) {
                        for (print_line_len..self.w - 2) |_| {
                            std.debug.print(" ", .{});
                        }
                    }

                    last_line_id += 1;
                } else {
                    for (0..(self.w - 2)) |_| {
                        std.debug.print(" ", .{});
                    }

                    last_row_id += 1;

                    last_line_id = 0;
                }
            } else {
                for (0..(self.w - 2)) |_| {
                    std.debug.print(" ", .{});
                }
            }
            std.debug.print("│\n", .{});
        }

        std.debug.print("╰", .{});
        for (0..(self.w - 2)) |_| {
            std.debug.print("─", .{});
        }
        std.debug.print("╯\n", .{});

        if (self.enablve_input) {
            std.debug.print("{s}| ", .{self.promt});
        }
    }
};
