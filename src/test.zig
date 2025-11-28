const std = @import("std");
const ztui = @import("main.zig");
const Word = @import("Word.zig");

pub fn main() !void {
    var win = try ztui.tui().init(.{.w = 30}, std.heap.page_allocator);
    defer win.deinit();

    win.input_init(.{.promt = "Hello"});

    win.draw();

    var buff: [32]u8 = undefined;
    const answer = try win.hearing(&buff);

    if (std.mem.eql(u8, answer, "hi")) {
        try win.append_row("zTUI test text!", std.heap.page_allocator);
        win.draw();

    }

}
