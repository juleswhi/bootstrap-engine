const std = @import("std");
const rl = @import("raylib");
const ecs = @import("ecs");
const comp = @import("components/components.zig");
const systems = @import("systems.zig");
const debug = @import("log.zig").debug;

pub fn main() !void {
    var reg = ecs.Registry.init(std.heap.page_allocator);

    const width = 800;
    const height = 450;

    createPlayer(&reg, width, height);
    createGround(&reg, width, height);
    createWalls(&reg, width, height);

    rl.initWindow(width, height, "platformer");
    defer rl.closeWindow();
    rl.setTargetFPS(240);

    var last_frame_time = rl.getTime();

    while (!rl.windowShouldClose()) {
        const current_time = rl.getTime();
        const dt: f32 = @floatCast(current_time - last_frame_time);
        last_frame_time = current_time;

        systems.inputSystem(&reg, dt);
        systems.gravitySystem(&reg, dt);
        systems.movementSystem(&reg, dt);
        systems.collisionSystem(&reg);

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.drawFPS(width - 100, 10);

        rl.clearBackground(.black);

        systems.renderSystem(&reg);
    }
}

fn createPlayer(reg: *ecs.Registry, width: f32, _: f32) void {
    const entity = reg.create();
    reg.add(entity, comp.Position.new(width / 2, 10));
    reg.add(entity, comp.Velocity.new(0, 0));
    reg.add(entity, comp.Size.new(25, 40));
    reg.add(entity, comp.Colour.new(255, 255, 255, 255));
    reg.add(entity, comp.Jump{});
    reg.add(entity, comp.Grounded{});
    reg.add(entity, comp.PlayerTag{});
    reg.add(entity, comp.GravityTag{});
    reg.add(entity, comp.RenderTag{});
}

fn createGround(reg: *ecs.Registry, width: f32, height: f32) void {
    const entity = reg.create();
    const ground_height = 30;

    reg.add(entity, comp.Position.new(0, height + 10));
    reg.add(entity, comp.Size.new(width, ground_height));
    reg.add(entity, comp.Colour.new(0, 255, 0, 255));
    reg.add(entity, comp.GroundTag{});
    reg.add(entity, comp.RenderTag{});
}

fn createWalls(reg: *ecs.Registry, width: f32, height: f32) void {
    const left_wall_entity = reg.create();
    reg.add(left_wall_entity, comp.Position.new(0 - 10, 0));
    reg.add(left_wall_entity, comp.Size.new(40, height + 50));
    reg.add(left_wall_entity, comp.Colour.new(0, 255, 0, 255));
    reg.add(left_wall_entity, comp.GroundTag{});

    const right_wall_entity = reg.create();
    reg.add(right_wall_entity, comp.Position.new(width - 30, 0));
    reg.add(right_wall_entity, comp.Size.new(40, height + 50));
    reg.add(right_wall_entity, comp.Colour.new(0, 255, 0, 255));
    reg.add(right_wall_entity, comp.GroundTag{});

    const floater_entity = reg.create();
    reg.add(floater_entity, comp.Position.new(500, 420));
    reg.add(floater_entity, comp.Size.new(200, 500));
    reg.add(floater_entity, comp.Colour.new(0, 255, 0, 255));
    reg.add(floater_entity, comp.GroundTag{});
    reg.add(floater_entity, comp.RenderTag{});

    const floater_entity_two = reg.create();
    reg.add(floater_entity_two, comp.Position.new(0, 385));
    reg.add(floater_entity_two, comp.Size.new(300, 500));
    reg.add(floater_entity_two, comp.Colour.new(0, 255, 0, 255));
    reg.add(floater_entity_two, comp.GroundTag{});
    reg.add(floater_entity_two, comp.RenderTag{});
}
