const std = @import("std");
const ztui = @import("root.zig");

pub fn main() !void {
    var win = try ztui.tui().init(.{ .w = try ztui.getTerminalWidth(), .h = try ztui.getTerminalHeigth() }, std.heap.page_allocator);
    defer win.deinit();

    var buff: [1024]u8 = undefined;

    try win.inputInit(.{ .prompt = "Hello" }, &buff);

    win.draw();

    const answer = try win.hearing();

    if (std.mem.eql(u8, answer, "hi")) {
        try win.appendRow("zTUI test text", .{ .color = .blue });
        try win.appendRow("zTUI test text", .{ .color = .blue });

        win.draw();

        win.clearRow(.{});
        try win.appendProgressBar(0);

        win.draw();

        for (0..101) |p| {
            try win.setProgressBar(p, 0);
            win.draw();
            std.Thread.sleep(std.time.ns_per_s);
        }

        win.clearProgressBar(.{});
        win.rename("Echo");
        try win.reprompt("echo", .{ .color = .green });

        win.draw();

        const a2 = try win.hearing();
        try win.appendRow(a2, .{ .color = .green });
        win.draw();
    }
}
