const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Get Linux display backend option (default to x11)
    const linux_display_backend = b.option([]const u8, "linux_display_backend", "Linux display backend (x11 or wayland)") orelse "x11";

    // Create options for raylib
    const raylib_options = b.addOptions();
    raylib_options.addOption([]const u8, "linux_display_backend", linux_display_backend);

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "bootstrap",
        .root_module = exe_mod,
    });

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
        .linux_display_backend = linux_display_backend,
    });

    const ecs_dep = b.dependency("ecs", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = raylib_dep.module("raylib");
    const raygui = raylib_dep.module("raygui");
    const raylib_artifact = raylib_dep.artifact("raylib");
    const ecs = ecs_dep.module("zig-ecs");

    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("ecs", ecs);
    exe.root_module.addImport("raygui", raygui);
    exe.root_module.addOptions("raylib_options", raylib_options);

    if (target.getOsTag() == .windows) {
        exe.addWin32ResourceFile(.{ .file = .{ .path = "resources.rc" } });
    }

    b.installArtifact(exe);

    const exe_check = b.addExecutable(.{
        .name = "foo",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    run_exe_unit_tests.addFileInput(b.path("src/tests.zig"));

    const check = b.step("check", "Check if foo compiles");
    check.dependOn(&exe_check.step);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
