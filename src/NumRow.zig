const std = @import("std");
const Word = @import("Word.zig");
const Color = @import("Color.zig");
const Settings = @import("Settings.zig");

pub const NumRow = struct {
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

    fn wordProcessing(allocator: std.mem.Allocator, text: []const u8, settings: Settings.RowSettings, w: usize, i: usize) !std.ArrayList([]const u8) {
    		const wrapped = try Word.wrapText(w - 2, text, allocator);
        var numbered = std.ArrayList([]const u8).init(allocator);

        const idx = i;

        for (wrapped.items) |line| {
            const prefixed = try std.fmt.allocPrint(allocator, "{d}.{s}", .{ idx, line });
            try numbered.append(prefixed);
        }

        const inc_text = try Word.applyIndentation(allocator, numbered, settings.indentation);

        if (settings.color != .none) {
            const color_text = try Color.colorize(inc_text, settings.color, allocator);
            return color_text;
        } else {
			return inc_text;
        }
    }

    pub fn append(self: *Self, w: usize, row: []const u8, settings: Settings.RowSettings) !void {
		const text = try wordProcessing(self.allocator, row, settings, w, self.rows.items.len + 1);

		try self.rows.append(text);
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

    pub fn setNumRow(self: *Self, w: usize, index: usize, new_row: []const u8, settings: Settings.RowSettings) !void {
		if (index >= self.rows.items.len) return error.InvalidSetIndex;

		const text = try wordProcessing(self.allocator, new_row, settings, w, index + 1);

    		self.rows.items[index] = text;
    	}
};
