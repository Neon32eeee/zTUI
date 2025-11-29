const std = @import("std");
const ztui = @import("main.zig");

pub fn main() !void {
    var win = try ztui.tui().init(.{.w = try ztui.getTerminalWidth(), .h = 10}, std.heap.page_allocator);
    defer win.deinit();

    win.input_init(.{.promt = "Hello"});

    win.draw();

    var buff: [32]u8 = undefined;
    const answer = try win.hearing(&buff);

    if (std.mem.eql(u8, answer, "hi")) {
        try win.append_row("zTUI test text!");
        win.draw();

    }

}
