const ecs = @import("ecs");
const std = @import("std");
const rl = @import("raylib");
const comp = @import("components/components.zig");
const Level = @import("level.zig").Level;
const Rect = @import("level.zig").Rect;
const debug = @import("log.zig").debug;
const serialiser = @import("serializer.zig");
const systems = @import("systems.zig");
const tests = @import("tests.zig");
const loadTextures = @import("systems/animate.zig").loadTextures;
const unloadTextures = @import("systems/animate.zig").unloadTextures;

pub fn main() !void {
    var reg = ecs.Registry.init(std.heap.page_allocator);

    const width = 1500;
    const height = 800;

    createPlayer(&reg, width, height);

    const json = try serialiser.readJsonFile(std.heap.page_allocator, "levels/level_one.json");
    defer std.heap.page_allocator.free(json);

    var level = try serialiser.deserialiseLevel(json);
    defer std.heap.page_allocator.free(level.rects);

    level.add_ecs(&reg);


    rl.initWindow(width, height, "Bootstrap Engine");
    defer rl.closeWindow();
    rl.setTargetFPS(240);


    try loadTextures(&reg);

    var frame_counter: u32 = 0;
    var last_frame_time = rl.getTime();

    while (!rl.windowShouldClose()) {
        const current_time = rl.getTime();
        const dt: f32 = @floatCast(current_time - last_frame_time);
        last_frame_time = current_time;
        frame_counter += 1;

        try systems.Input(&reg, dt);
        systems.Dodge(&reg, dt);
        systems.Gravity(&reg, dt);
        systems.Movement(&reg, dt);
        systems.Collision(&reg);
        systems.Animate(&reg, &frame_counter);

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.drawFPS(width - 100, 10);
        rl.clearBackground(.black);

        systems.Render(&reg);
    }

    try unloadTextures(&reg);
}

fn createPlayer(reg: *ecs.Registry, width: f32, _: f32) void {
    const entity = reg.create();
    reg.add(entity, comp.Position.new(width / 2, 10));
    reg.add(entity, comp.Velocity.new(0, 0));
    reg.add(entity, comp.Size.new(25, 40));
    reg.add(entity, comp.Colour.new(255, 255, 255, 255));
    reg.add(entity, comp.Dodge{ .speed = 1500 });
    reg.add(entity, comp.Animate{});
    reg.add(entity, comp.Jump{});
    reg.add(entity, comp.Grounded{});
    reg.add(entity, comp.PlayerTag{});
    reg.add(entity, comp.GravityTag{});
}

test {
    _ = tests;
}
