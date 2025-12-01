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

## How to Install
Installation via fetch
```
zig fetch --save https://github.com/Neon32eeee/zTUI/archive/refs/tags/0.0.2.tar.gz
```

add for build.zig
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "myproject",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

+    const ztui = b.dependency("ztui", .{
+        .target = target,
+        .optimize = optimize,
+    });

+    exe.root_module.addImport("ztui", ztui.module("ztui"));

    b.installArtifact(exe);
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

    try win.appendRow("zTUI test text!");

    win.draw();
}
```

### Analysis

#### `try win.appendRow("zTUI test text!");`
The `appendRow` method accepts 1 argument, which is the string we want to add. First, it breaks the text and wraps words if necessary, but if a word is longer than the width itself, an error will be issued. It simply adds this edited string to `win.rows`, which stores these strings, and the `win.draw();` method renders them in order from the 0th element to the last.

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

    try win.appendNumRow("zTUI test text!");

    win.draw();
}
```

### Analysis

#### `try win.appendNumRow("zTUI test text!");`
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

Example with the user input system

```
const std = @import("std");
const ztui = @import("ztui");

pub fn main() !void {
    var win = try ztui.tui().init(.{.w = 30, .h = 10}, std.heap.page_allocator);
    defer win.deinit();

    win.inputInit(.{.promt = "Hello"});

    win.draw();

    var buff: [32]u8 = undefined;
    const answer = try win.hearing(&buff);

    if (std.mem.eql(u8, answer, "hi")) {
        try win.appendRow("input system works!");
        win.draw();
    }

}
```

### Analysis

#### 1.`win.inputInit(.{.promt = "Hello"});`
Here we initialize the input system so that we can listen for user input in the future. The method itself accepts input system settings, which include:

- `promt` - this is the prompt for the user that appears at the end and next to the input field.
  
#### 2.`const answer = try win.hearing(&buff);`
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

Using the `w` value for the current terminal size

```zig
const ztui = @import("ztui")

pub fn main() !void {
    const win = ztui.tui().init(.{.w = try ztui.getTerminalWidth()});

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
- draw

##### parameters :
- w
- h
- name
- enablve_input
- allocator
- rows
- num_rows
- promt
- input_enty

## TODO

- [x] Add func clear_row and clear_num_row
- [x] Rename func
- [ ] Rename paremeters
- [ ] Add row color set
- [ ] Add func rename