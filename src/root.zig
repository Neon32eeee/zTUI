const std = @import("std");
const TUI = @import("TUI.zig");
const Terminal = @import("Termimal.zig");

pub const TUIType = TUI.TUI;

pub fn tui() type {
    return TUI.TUI;
}

pub fn getTerminalWidth() !usize {
    const stdout = std.fs.File.stdout();

    return (try Terminal.getTerminalSize(stdout)).?.width;
}

pub fn getTerminalHeigth() !usize {
    const stdout = std.fs.File.stdout();

    return (try Terminal.getTerminalSize(stdout)).?.height - 2;
}
