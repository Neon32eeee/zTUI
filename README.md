# zTUI

## About the Project
zTUI is an open-source library for TUI, with support for user input systems.
## Interface Examples
```
╭────────────────────────────╮
│zTUI                        │
│zTUI - it's an open source  │
│library for TUI, with       │
│support for user input      │
│systems.                    │
│                            │
╰────────────────────────────╯
```

## Support

zig version: `0.15.1`

OS:

    - Linux: `100%`
    - OS X: `100%`
    - Windows: ?

## How to Install
Installation via fetch
```
zig fetch --save https://github.com/Neon32eeee/zTUI/archive/refs/tags/0.1.1.tar.gz
```

add for build.zig
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addModule("myproject", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

+    const ztui = b.dependency("ztui", .{
+        .target = target,
+        .optimize = optimize,
+    });

+    const ztui_module = b.addModule("ztui", .{ .root_source_file = ztui.path("src/main.zig") });

    exe.root_module.addImport("ztui", ztui_module);

    b.installArtifact(exe);
}
```

## Project API
Basic script for a standard window
```
const std = @import("std");
const ztui = @import("ztui");

pub fn main() !void {
    const win = try ztui.tui().init(.{.w = 20, .h = 10}, std.heap.page_allocator);
    defer win.deinit();

    win.draw();
}
```
### Analysis

#### 1. `const win = try ztui.tui().init(.{.w = 20, .h = 10});` 

Here we declare a constant into which we initialize our application window. The `init` function itself accepts two arguments. The first is the settings, which is a structure with the following fields:

- `w` - this controls the **width** of the window. It should not be set higher than size terminal to avoid overloading the terminal. The default is 90.

- `h` - this is the **height** of our window. The default is 10.

- `name` - this field sets the **name** of the window. The default is zTUI.

The second argument is the allocator.

#### 2. `win.draw();`
Here we call the method on the structure that draws the window in the terminal.

### Expected Output
```
╭──────────────────╮
│zTUI              │
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
╰──────────────────╯
```


---

Another example with adding text to the window

```
const std =@import("std");
const ztui = @import("ztui");

pub fn main() !void {
    var win = try ztui.tui().init(.{.w = 20, .h = 10}, std.heap.page_allocator);
    defer win.deinit();

    try win.appendRow("zTUI test text!", .{});

    win.draw();
}
```

### Analysis

#### `try win.appendRow("zTUI test text!", .{});`
The `appendRow` method accepts 2 argument, which is the string we want to add. First, it breaks the text and wraps words if necessary, but if a word is longer than the width itself, an error will be issued. It simply adds this edited string to `win.rows`, which stores these strings, and the `win.draw();` method renders them in order from the 0th element to the last.  The second argument is responsible for the settings:

- color:
  - `red`
  - `green`
  - `yellow`
  - `blue`
- indentation:
  -  defines the number of sharps for a row


### Expected Output
```
╭──────────────────╮
│zTUI              │
│zTUI test text!   │
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
╰──────────────────╯
```

---

Example with numbered lines 
```zig
const std =@import("std");
const ztui = @import("ztui");

pub fn main() !void {
    var win = try ztui.tui().init(.{.w = 20, .h = 10}, std.heap.page_allocator);
    defer win.deinit();

    try win.appendNumRow("zTUI test text!", .{});

    win.draw();
}
```

### Analysis

#### `try win.appendNumRow("zTUI test text!", .{});`
Here we call a method that works almost the same as `win.appendRow`, but additionally places the text into `num_rows`. During `draw`, it will be displayed as a numbered line starting from 1.  
It’s important to note that `num_rows` has lower priority than `rows` when rendering.

### Expected output
```
╭──────────────────╮
│zTUI              │
│1.zTUI test text! │
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
╰──────────────────╯
```
--- 

Using a progress bar

```
const std = @import("std");
const ztui = @import("ztui");

pub fn main() !void {
    var win = try ztui.tui().init(.{.w = 20, .h = 10}, std.heap.page_allocator);
    defer win.deinit();
    
    try win.appendProgressBar(0);
    
    for (0..100) |i| {
        try win.setProgressBar(i, 0);
        std.time.sleep(std.time.ns_per_s);
        win.draw();
    }
}
```

### Analysis

1. `try win.appendProgressBar(0);`

Creates a progress bar at 0%, the value cannot exceed 100. It also adjusts to the size of the window itself, that is, there are only 3 sizes: 4, 10 and 100 ind.

2. `try win.setProgressBar(i, 0);`

Sets a new percentage at the specified index.

### Expected Output

####  On first program launch
```
╭──────────────────╮
│zTUI              │
│      ----------0%│
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
╰──────────────────╯
```
#### after 99 seconds
```
╭──────────────────╮
│zTUI              │
│     #########-99%│
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
╰──────────────────╯

```

####
---

Example with the user input system

```
const std = @import("std");
const ztui = @import("ztui");

pub fn main() !void {
    var win = try ztui.tui().init(.{.w = 30, .h = 10}, std.heap.page_allocator);
    defer win.deinit();

    var buff: [32]u8 = undefined;

    try win.inputInit(.{.prompt = "Hello"}, &buff);

    win.draw();
    const answer = try win.hearing();

    if (std.mem.eql(u8, answer, "hi")) {
        try win.appendRow("input system works!", .{});
        win.draw();
    }

}
```

### Analysis

#### 1.`try win.inputInit(.{.prompt = "Hello"}, &buff);`
Here we initialize the input system so that we can listen for user input in the future. The method itself accepts input system settings, which include:

- `prompt` - this is the prompt for the user that appears at the end and next to the input field.
- `color_prompt` - This parameter defines the value for the prompt. The colors are the same as in Row.
  
#### 2.`const answer = try win.hearing();`
Here we call the method on the structure that listens for user input. Once the user enters text, it returns the input. The method accepts a buffer, which should ideally be sized to match the presumed maximum input size to avoid taking up too much memory.

### Expected Output

#### On first program launch
```
╭────────────────────────────╮
│zTUI                        │
│                            │
│                            │
│                            │
│                            │
│                            │
│                            │
│                            │
│                            │
│                            │
╰────────────────────────────╯
Hello| 
```

#### Upon entering "hi"
```
╭────────────────────────────╮
│zTUI                        │
│input system works!         │
│                            │
│                            │
│                            │
│                            │
│                            │
│                            │
│                            │
│                            │
╰────────────────────────────╯
```

---

Using the value for the current terminal size

```zig
const ztui = @import("ztui")

pub fn main() !void {
    const win = ztui.tui().init(.{.w = try ztui.getTerminalWidth(), .h = try ztui.getTerminalHeigth()});

    win.draw();
}
````

-----

### Analysis

#### try ztui.getTerminalWidth()

This is a function that takes no arguments but returns the current size (width) of the terminal.

---

### All func and parameters 

#### TUI 
##### Func :
- init
- deinit
- inputInit
- hearing
- appendRow
- appendNumRow
- clearRow
- clearNumRow
- setRow 
- setNumRow
- appendProgressBar
- clearProgressBar
- setProgressBar
- rename
- reprompt
- draw

##### parameters :
- w
- h
- name
- enable_input
- allocator
- row
- num_row
- progress_bar
- prompt
- input_entry

#### General API 

#### Func :
- tui
- getTrminalWidth
- getTrminalHeigth

#### Consts :
- TUIType

## TODO (0.1.2)


## License

MIT License

Versions prior to 0.0.5 were licensed under GPL-3.0.
