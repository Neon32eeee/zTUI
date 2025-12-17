const std = @import("std");

pub const ProgressBar = struct {
    progress_bars: std.ArrayList([]const u8),
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        const progress_bars = std.ArrayList([]const u8).init(allocator);

        const self = Self{ .progress_bars = progress_bars, .allocator = allocator };

        return self;
    }

    pub fn deinit(self: *Self) void {
        self.progress_bars.deinit();
    }

    fn writeProchent(line: []u8, prochent: usize, bigin_index: usize) void {
        const digits = "0123456789";
        if (prochent == 100) {
            line[bigin_index] = '1';
            line[bigin_index + 1] = '0';
            line[bigin_index + 2] = '0';
            line[bigin_index + 3] = '%';
        } else if (prochent >= 10) {
            line[bigin_index] = digits[prochent / 10];
            line[bigin_index + 1] = digits[prochent % 10];
            line[bigin_index + 2] = '%';
        } else {
            line[bigin_index] = digits[prochent];
            line[bigin_index + 1] = '%';
        }
    }

    pub fn append(self: *Self, w: usize, prochent: usize) !void {
        if (prochent > 100) return error.InvalidProchent;
        if (w < 8) return;

        const bar_len: usize = if (w < 14) 4 else if (w < 104) 10 else 100;
        const percent_len: usize = if (prochent == 100) 4 else if (prochent >= 10) 3 else 2;

        const used_len = bar_len + percent_len;

        var line = try self.allocator.alloc(u8, used_len);
        @memset(line, ' ');

        if (w >= 8 and w < 14) {
            const complited: usize = prochent / 25;

            inline for (0..4) |i| {
                line[i] = if (complited > i) '#' else '-';
            }

            writeProchent(line, prochent, 4);
        }
        if (w >= 14 and w < 104) {
            const complited: usize = prochent / 10;

            inline for (0..10) |i| {
                line[i] = if (complited > i) '#' else '-';
            }

            writeProchent(line, prochent, 10);
        }

        if (w >= 104) {
            inline for (0..100) |i| {
                line[i] = if (prochent > i) '#' else '-';
            }

            writeProchent(line, prochent, 100);
        }

        try self.progress_bars.append(line[0..]);
    }

    pub fn clearAll(self: *Self) void {
        self.progress_bars.clearAndFree();
    }

    pub fn clearIndex(self: *Self, i: usize) void {
        _ = self.progress_bars.orderedRemove(i);
    }

    pub fn set(self: *Self, w: usize, prochent: usize, index: usize) !void {
        if (prochent > 100) return error.InvalidProchent;
        if (w < 8) return;

        const bar_len: usize = if (w < 14) 4 else if (w < 104) 10 else 100;
        const percent_len: usize = if (prochent == 100) 4 else if (prochent >= 10) 3 else 2;

        const used_len = bar_len + percent_len;

        var line = try self.allocator.alloc(u8, used_len);
        @memset(line, ' ');

        const complited: usize = prochent / if (8 >= w and w < 14) @as(usize, 25)
        		else if (w >= 14 and w < 104)
        			@as(usize, 10)
        		else
        			@as(usize, 1);

        for (0..bar_len) |i| {
            line[i] = if (complited > i) '#' else '-';
        }

        writeProchent(line, prochent, bar_len);

        self.progress_bars.items[index] = line;
    }
};
