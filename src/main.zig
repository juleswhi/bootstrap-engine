const std = @import("std");
const rl = @import("raylib");

pub fn main() !void {
    std.debug.print("Hello World!\n", .{});
    const width = 800;
    const height = 450;

    rl.initWindow(width, height, "platformer");

    defer rl.closeWindow();

    rl.setTargetFPS(120);

    while(!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);
    }
}
