const std = @import("std");
const ztui = @import("main.zig");

pub fn main() !void {
    var win = try ztui.tui().init(.{ .w = try ztui.getTerminalWidth(), .h = try ztui.getTerminalHeigth() }, std.heap.page_allocator);
    defer win.deinit();

    try win.inputInit(.{ .prompt = "Hello" });

    win.draw();

    var buff: [1024]u8 = undefined;
    const answer = try win.hearing(&buff);

    if (std.mem.eql(u8, answer, "hi")) {
        try win.appendRow("zTUI test text", .{ .color = .blue });

        win.draw();

        win.clearRow(.{});
    		try win.appendProgressBar(0);

    		win.draw();

    		for (0..51) |p| {
    			try win.setProgressBar(p * 2, 0);
    			win.draw();
    			std.time.sleep(std.time.ns_per_s);
    		}

		win.clearProgressBar(.{});
        win.rename("Echo");
        try win.reprompt("echo", .{ .color = .green });

        win.draw();

        const a2 = try win.hearing(&buff);
        try win.appendRow(a2, .{ .color = .green });
        win.draw();
    }
}
