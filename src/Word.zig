const std = @import("std");

fn wordWidth(word: []const u8) usize {
    var width: usize = 0;
    var i: usize = 0;
    while (i < word.len) {
        const len = std.unicode.utf8ByteSequenceLength(word[i]) catch return width;
        width += 1;
        i += len;
    }
    return width;
}

pub fn wrapText(w: usize, t: []const u8, allocator: std.mem.Allocator) !std.ArrayList([]const u8) {
    var it = std.mem.splitScalar(u8, t, ' ');
    var corrent_row = std.ArrayList([]const u8).init(allocator);

    var line_buff = std.ArrayList(u8).init(allocator);

    const writer = line_buff.writer();

    const len_none: usize = 1;
    var last_w: usize = w;
    while (it.next()) |word| {
        const len = wordWidth(word);
        const final_word_len: usize = if (line_buff.items.len == 0) len else len_none + len;

        if (final_word_len <= last_w) {
            if (line_buff.items.len > 0) {
                try writer.writeAll(" ");
            }

            try writer.writeAll(word);

            last_w -= final_word_len;
        } else {
            if (line_buff.items.len > 0) {
                const final_line = try line_buff.toOwnedSlice();
                try corrent_row.append(final_line);
            }

            line_buff.items.len = 0;
            try line_buff.appendSlice(word);

            last_w = w - len;
        }
    }

    if (line_buff.items.len > 0) {
        const final_line = try line_buff.toOwnedSlice();
        try corrent_row.append(final_line);
    }

    return corrent_row;
}

pub fn applyIndentation(allocator: std.mem.Allocator, t: std.ArrayList([]const u8), indentation: usize) !std.ArrayList([]const u8) {
    if (indentation == 0 or t.items.len == 0) return t;

    const indent = try allocator.alloc(u8, indentation);
    @memset(indent, ' ');

    const old_first = t.items[0];
    t.items[0] = try std.mem.concat(allocator, u8, &.{ indent, old_first });

    allocator.free(old_first);
    allocator.free(indent);

    return t;
}
