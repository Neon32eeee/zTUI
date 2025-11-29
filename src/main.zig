const std = @import("std");
const TUI = @import("TUI.zig");
const Terminal = @import("Termimal.zig");

pub fn tui() type {
   return TUI.TUI;
}

pub fn getTerminalWidth() !usize {
    const stdout = std.io.getStdOut();

    return (try Terminal.getTerminalSize(stdout)).?.width;
}

