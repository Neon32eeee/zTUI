const std = @import("std");
const Input = @import("Input.zig");
const Row = @import("Row.zig");
const NumRow = @import("NumRow.zig");
const ProgressBar = @import("RrogressBar.zig");
const Color = @import("Color.zig");
const Settings = @import("Settings.zig");

pub const TUI = struct {
    w: usize,
    h: usize,
    name: []const u8,
    enable_input: bool,
    allocator: std.mem.Allocator,

    row: Row.Row,
    num_row: NumRow.NumRow,
    progress_bar: ProgressBar.ProgressBar,

    prompt: []const u8,
    input_entry: Input.Input = Input.Input.init(),

    const Self = @This();

    pub fn init(setting: Settings.TUISettings, allocator: std.mem.Allocator) !Self {
        if (setting.w > (try @import("Termimal.zig").getTerminalSize(std.io.getStdOut())).?.width) return error.InvalidWethg;
        if (setting.w <= 0) return error.InvalidWethg;

        const rows = Row.Row.init(allocator);
        const num_rows = NumRow.NumRow.init(allocator);
        const progress_bar = ProgressBar.ProgressBar.init(allocator);

        const self = Self{ .w = setting.w, .h = setting.h, .name = setting.name, .enable_input = false, .row = rows, .num_row = num_rows, .progress_bar = progress_bar, .prompt = "", .allocator = allocator };

        return self;
    }

    pub fn deinit(self: *Self) void {
        progress_barself.row.deinit();
        self.num_row.deinit();
        self.progress_bar.deinit();
    }

    pub fn inputInit(self: *Self, setting: Settings.InputSettings) !void {
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

    pub fn appendRow(self: *Self, row: []const u8, settings: Settings.RowSettings) !void {
        try self.row.append(self.w, row, settings);
    }

    pub fn appendNumRow(self: *Self, row: []const u8, settings: Settings.RowSettings) !void {
        try self.num_row.append(self.w, row, settings);
    }

    pub fn clearRow(self: *Self) void {
        self.row.clear();
    }

    pub fn clearNumRow(self: *Self) void {
        self.num_row.clear();
    }

    pub fn setRow(self: Self, index: usize, new_row: []const u8, settings: Settings.RowSettings) !void {
        try self.row.setRow(self.w, index, new_row, settings);
    }

    pub fn setNumRow(self: Self, index: usize, new_row: []const u8, settings: struct { color: Color.ColorName = .none }) !void {
        try self.num_row.setNumRow(self.w, index, new_row, settings);
    }

    pub fn appendProgressBar(self: *Self, prochent: usize) !void {
        try self.progress_bar.append(self.w - 2, prochent);
    }

    pub fn clearProgressBar(self: *Self, settings: Settings.ProgressBarClearSettings) !void {
        if (settings.index > 0) {
            self.progress_bar.clearIndex(settings.index);
        } else {
            self.progress_bar.clearAll();
        }
    }

    pub fn setProgressBar(self: *Self, prochent: usize, index: usize) void {
        self.progress_bar.set(self.w - 2, prochent, index);
    }

    pub fn rename(self: *Self, new_name: []const u8) void {
        self.name = new_name;
    }

    pub fn reprompt(self: *Self, new_prompt: []const u8, settings: Settings.ColorSettings) !void {
        if (settings.color != .none) {
            const color_prompt = try Color.colorize_text(new_prompt, settings.color, self.allocator);
            self.prompt = color_prompt;
        } else {
            self.prompt = new_prompt;
        }
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

        for (self.row.rows.items) |row| {
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

        for (self.num_row.rows.items) |row| {
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
