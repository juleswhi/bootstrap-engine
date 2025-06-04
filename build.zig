const std = @import("std");

fn ensureDirExists(b: *std.Build, dir: std.Build.LazyPath) void {
    const mkdir_step = b.addSystemCommand(&.{ "cmd", "/c", "mkdir" });
    mkdir_step.addDirectoryArg(dir);
    mkdir_step.step.dependOn(b.getInstallStep());
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "bootstrap",
        .root_module = exe_mod,
    });

    if (target.result.os.tag == .windows) {
        exe.subsystem = .Windows;
        exe.win32_manifest = b.path("manifest.manifest");
    }

    const raylib_options = b.addOptions();
    raylib_options.addOption([]const u8, "linux_display_backend", "x11");

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
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

    if (target.result.os.tag == .windows) {
        const install_dir = b.getInstallPath(.bin, "");
        ensureDirExists(b, .{ .src_path = .{ .owner = b, .sub_path = install_dir } });

        const install_step = b.addInstallArtifact(exe, .{});
        install_step.dest_dir = .{ .custom = "" };

        b.getInstallStep().dependOn(&install_step.step);
    } else {
        b.installArtifact(exe);
    }

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

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
