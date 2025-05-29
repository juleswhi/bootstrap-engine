const std = @import("std");
const rl = @import("raylib");
const ecs = @import("ecs");
const comp = @import("components/components.zig");
const systems = @import("systems.zig");

pub fn main() !void {
    var reg = ecs.Registry.init(std.heap.page_allocator);

    const width = 800;
    const height = 450;

    createPlayer(&reg, width, height);
    createGround(&reg, width, height);

    rl.initWindow(width, height, "platformer");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {

        systems.inputSystem(&reg);

        systems.movementSystem(&reg);

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.black);

        systems.renderSystem(&reg);

    }
}

fn toInt(f: f32) i32 {
    return @intFromFloat(f);
}

fn createPlayer(reg: *ecs.Registry, width: f32, height: f32) void {
    const entity = reg.create();
    reg.add(entity, comp.Position.new(width / 2, height / 2));
    reg.add(entity, comp.Velocity.new(0, 0));
    reg.add(entity, comp.Size.new(100, 200));
    reg.add(entity, comp.Colour.new(0, 255, 0, 255));
    reg.add(entity, comp.PlayerTag{});
}

fn createGround(reg: *ecs.Registry, width: f32, height: f32) void {
    const entity = reg.create();

    const ground_height = 30;

    reg.add(entity, comp.Position.new(0, height + ground_height));
    reg.add(entity, comp.Size.new(width, ground_height));
    reg.add(entity, comp.Colour.new(255, 0, 0, 255));
    reg.add(entity, comp.GroundTag{});
}
