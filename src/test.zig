const std = @import("std");
const ztui = @import("main.zig");

pub fn main() !void {
    var win = try ztui.tui().init(.{ .w = try ztui.getTerminalWidth(), .h = 10 }, std.heap.page_allocator);
    defer win.deinit();

    win.inputInit(.{ .prompt = "Hello" });

    win.draw();

    var buff: [32]u8 = undefined;
    const answer = try win.hearing(&buff);

    if (std.mem.eql(u8, answer, "hi")) {
        try win.appendRow("zTUI test text!", .{ .color = .red });
        win.draw();

        win.clearRow();
        win.rename("Echo");
        win.reprompt("echo");

        win.draw();
        const a2 = try win.hearing(&buff);
        try win.appendRow(a2, .{});
        win.draw();
    }
}
