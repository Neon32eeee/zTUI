const std = @import("std");
const Input = @import("Input.zig");
const Word = @import("Word.zig");
const Color = @import("Color.zig");

pub const TUISettings = struct {
    w: usize = 90,
    h: usize = 10,
    name: []const u8 = "zTUI",
};

const InputSettings = struct { prompt: []const u8, color_promt: Color.ColorName = .none };

const ColorSettings = struct { color: Color.ColorName = .none };

pub const TUI = struct {
    w: usize,
    h: usize,
    name: []const u8,
    enable_input: bool,
    allocator: std.mem.Allocator,

    rows: std.ArrayList(std.ArrayList([]const u8)),
    num_rows: std.ArrayList(std.ArrayList([]const u8)),

    prompt: []const u8,
    input_entry: Input.Input = Input.Input.init(),

    const Self = @This();

    pub fn init(setting: TUISettings, allocator: std.mem.Allocator) !Self {
        if (setting.w > (try @import("Termimal.zig").getTerminalSize(std.io.getStdOut())).?.width) return error.InvalidWethg;
        if (setting.w <= 0) return error.InvalidWethg;

        const rows = std.ArrayList(std.ArrayList([]const u8)).init(allocator);
        const num_rows = std.ArrayList(std.ArrayList([]const u8)).init(allocator);

        const self = Self{ .w = setting.w, .h = setting.h, .name = setting.name, .enable_input = false, .rows = rows, .num_rows = num_rows, .prompt = "", .allocator = allocator };

        return self;
    }

    pub fn deinit(self: *Self) void {
        const allocator = self.allocator;

        for (self.rows.items) |row_list| {
            for (row_list.items) |line| {
                allocator.free(line);
            }

            row_list.deinit();
        }

        self.rows.deinit();

        for (self.num_rows.items) |num_row_list| {
            for (num_row_list.items) |line| {
                allocator.free(line);
            }
            num_row_list.deinit();
        }

        self.num_rows.deinit();
    }

    pub fn inputInit(self: *Self, setting: InputSettings) void {
        self.enable_input = true;

        if (setting.color_promt != .none) {
            const color_prompt = try Color.colorize_text(setting.prompt, setting.color_promt, self.allocator);
            self.prompt = color_prompt;
        } else {
            self.prompt = setting.prompt;
        }
    }

    pub fn hearing(self: *const Self, buffer: []u8) ![]const u8 {
        const result = try self.input_entry.hearing(buffer);

        if (result.len == 0) {
            return "";
        }

        return result;
    }

    pub fn appendRow(self: *Self, row: []const u8, color: ColorSettings) !void {
        const text = try Word.wrapText(self.w - 2, row, self.allocator);

        if (color.color != .none) {
            const color_text = try Color.colorize(text, color.color, self.allocator);
            try self.rows.append(color_text);
        } else {
            try self.rows.append(text);
        }
    }

    pub fn appendNumRow(self: *Self, row: []const u8, color: ColorSettings) !void {
        const wrapped = try Word.wrapText(self.w - 2, row, self.allocator);
        var numbered = std.ArrayList([]const u8).init(self.allocator);

        const idx = self.num_rows.items.len + 1;

        for (wrapped.items) |line| {
            const prefixed = try std.fmt.allocPrint(self.allocator, "{d}.{s}", .{ idx, line });
            try numbered.append(prefixed);
        }

        if (color.color != .none) {
            const color_text = try Color.colorize(numbered, color.color, self.allocator);
            try self.rows.append(color_text);
        } else {
            try self.num_rows.append(numbered);
        }
    }

    fn cleanupRows(rows_list: *std.ArrayList(std.ArrayList([]const u8)), allocator: std.mem.Allocator) void {
        for (rows_list.items) |row_list| {
            for (row_list.items) |line| {
                allocator.free(line);
            }
            row_list.deinit();
        }
        rows_list.clearAndFree();
    }

    pub fn clearRow(self: *Self) void {
        cleanupRows(&self.rows, self.allocator);
    }

    pub fn clearNumRow(self: *Self) void {
        cleanupRows(&self.num_rows, self.allocator);
    }

    pub fn rename(self: *Self, new_name: []const u8) void {
        self.name = new_name;
    }

    pub fn reprompt(self: *Self, new_prompt: []const u8) void {
        self.prompt = new_prompt;
    }

    fn displayWidth(slice: []const u8) usize {
        var width: usize = 0;
        var i: usize = 0;
        while (i < slice.len) {
            if (slice[i] == 0x1B) {
                i += 1;

                while (i < slice.len) : (i += 1) {
                    if (slice[i] == 'm') {
                        i += 1;
                        break;
                    }
                }
                continue;
            }

            const char_len = std.unicode.utf8ByteSequenceLength(slice[i]) catch 1;
            width += 1;
            i += char_len;
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

        var printed_lines: usize = 0;

        for (self.rows.items) |row| {
            if (printed_lines >= self.h - 2) break;
            for (row.items) |line| {
                if (printed_lines >= self.h - 2) break;
                std.debug.print("│{s}", .{line});
                const len = displayWidth(line);
                for (len..self.w - 2) |_| std.debug.print(" ", .{});
                std.debug.print("│\n", .{});
                printed_lines += 1;
            }
        }

        for (self.num_rows.items) |row| {
            if (printed_lines >= self.h - 2) break;
            for (row.items) |line| {
                if (printed_lines >= self.h - 2) break;
                std.debug.print("│{s}", .{line});
                const len = displayWidth(line);
                for (len..self.w - 2) |_| std.debug.print(" ", .{});
                std.debug.print("│\n", .{});
                printed_lines += 1;
            }
        }

        while (printed_lines < self.h - 2) : (printed_lines += 1) {
            std.debug.print("│", .{});
            for (0..self.w - 2) |_| std.debug.print(" ", .{});
            std.debug.print("│\n", .{});
        }

        std.debug.print("╰", .{});
        for (0..(self.w - 2)) |_| {
            std.debug.print("─", .{});
        }
        std.debug.print("╯\n", .{});

        if (self.enable_input) {
            std.debug.print("{s}| ", .{self.prompt});
        }
    }
};
