const std = @import("std");
const Word = @import("Word.zig");
const Color = @import("Color.zig");
const Settings = @import("Settings.zig");

pub const Row = struct {
    rows: std.ArrayList(std.ArrayList([]const u8)),
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        const row = std.ArrayList(std.ArrayList([]const u8)).init(allocator);

        const self = Self{ .rows = row, .allocator = allocator };

        return self;
    }

    pub fn deinit(self: Self) void {
        const allocator = self.allocator;

        for (self.rows.items) |row_list| {
            for (row_list.items) |line| {
                allocator.free(line);
            }

            row_list.deinit();
        }

        self.rows.deinit();
    }

    pub fn append(self: *Self, w: usize, row: []const u8, settings: Settings.RowSettings) !void {
        const text = try Word.wrapText(w - 2, row, self.allocator);

        const inc_text = try Word.applyIndentation(self.allocator, text, settings.indentation);

        if (settings.color != .none) {
            const color_text = try Color.colorize(inc_text, settings.color, self.allocator);
            try self.rows.append(color_text);
        } else {
            try self.rows.append(inc_text);
        }
    }

    pub fn clearAll(self: *Self) void {
        for (self.rows.items) |row_list| {
            for (row_list.items) |line| {
                self.allocator.free(line);
            }
            row_list.deinit();
        }
        self.rows.clearAndFree();
    }

    pub fn clearIndex(self: *Self, i: usize) void {
    		for (self.rows.items[i].items) |line| {
    			self.allocator.free(line);
    		}
    		self.rows.items[i].deinit();
    		_ = self.rows.orderedRemove(i);
    	}

    pub fn setRow(self: Self, w: usize, index: usize, new_row: []const u8, settings: Settings.RowSettings) !void {
        if (index >= self.rows.items.len) return error.InvalidSetIndex;

        const text = try Word.wrapText(w - 2, new_row, self.allocator);

        const inc_text = try Word.applyIndentation(self.allocator, text, settings.indentation);

        if (settings.color != .none) {
            const color_text = try Color.colorize(inc_text, settings.color, self.allocator);
            self.rows.items[index] = color_text;
        } else {
            self.rows.items[index] = inc_text;
        }
    }
};
