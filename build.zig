const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "ztui",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    const test_exe = b.addTest(.{ .name = "test", .root_source_file = b.path("src/test.zig"), .target = target, .optimize = optimize });

    const test_run = b.addRunArtifact(test_exe);

    const test_step_all = b.step("test", "test input TUI");
    test_step_all.dependOn(&test_run.step);
}
