const ecs = @import("ecs");
const std = @import("std");
const rl = @import("raylib");
const sd = @import("log.zig");
const comp = @import("components/components.zig");
const Level = @import("level.zig").Level;
const Rect = @import("level.zig").Rect;
const serialiser = @import("serializer.zig");
const systems = @import("systems.zig");
const tests = @import("tests.zig");
const loadTextures = @import("systems/animate.zig").loadTextures;
const unloadTextures = @import("systems/animate.zig").unloadTextures;
const Debug = @import("components/debug.zig").Debug;
const builtin = @import("builtin");

pub const FPS: i32 = 240;

pub fn main() !void {
    Debug.active = false;

    var reg = ecs.Registry.init(std.heap.page_allocator);
    defer reg.deinit();

    const width = 1500;
    const height = 820;

    try createPlayer(&reg, width, height);

    const json = if (builtin.os.tag == .windows) @embedFile("levels\\level_one.json") else @embedFile("levels/level_one.json");

    var level = try serialiser.deserialiseLevel(json);
    defer std.heap.page_allocator.free(level.rects);

    level.add_ecs(&reg);

    rl.initWindow(width, height, "Bootstrap Engine");
    defer rl.closeWindow();

    rl.setTargetFPS(FPS);

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

        systems.Render(&reg);

        rl.clearBackground(.black);
    }

    try unloadTextures(&reg);
}

fn createPlayer(reg: *ecs.Registry, width: f32, _: f32) !void {
    const entity = reg.create();

    reg.add(entity, comp.Hitbox.new(width / 2, 10, 48, 48));
    reg.add(entity, comp.Canvas{ .width = 96, .height = 96 });

    reg.add(entity, comp.Jump{});
    reg.add(entity, comp.Velocity.new(0, 0));
    reg.add(entity, comp.Grounded{});
    reg.add(entity, comp.Crouch{});

    reg.add(entity, comp.Dodge{ .speed = 1500 });

    const idle_png = if (builtin.os.tag == .windows) @embedFile("assets\\rain\\idle.png") else @embedFile("assets/rain/idle.png");
    const run_png = if (builtin.os.tag == .windows) @embedFile("assets\\rain\\run.png") else @embedFile("assets/rain/run.png");
    const jump_png = if (builtin.os.tag == .windows) @embedFile("assets\\rain\\jump.png") else @embedFile("assets/rain/jump.png");
    const punch_png = if (builtin.os.tag == .windows) @embedFile("assets\\rain\\punch.png") else @embedFile("assets/rain/punch.png");
    const roll_png = if (builtin.os.tag == .windows) @embedFile("assets\\rain\\roll.png") else @embedFile("assets/rain/roll.png");
    const dash_png = if (builtin.os.tag == .windows) @embedFile("assets\\rain\\dash.png") else @embedFile("assets/rain/dash.png");
    const land_png = if (builtin.os.tag == .windows) @embedFile("assets\\rain\\land.png") else @embedFile("assets/rain/land.png");
    const crouch_idle_png = if (builtin.os.tag == .windows) @embedFile("assets\\rain\\crouch-idle.png") else @embedFile("assets/rain/crouch-idle.png");
    const crouch_walk_png = if (builtin.os.tag == .windows) @embedFile("assets\\rain\\crouch-walk.png") else @embedFile("assets/rain/crouch-walk.png");

    var sprite_list = std.ArrayList(comp.Sprite).init(std.heap.page_allocator);
    try sprite_list.append(comp.Sprite.new("idle", idle_png, 10, 48, 48, 2, true, 0, 15));
    try sprite_list.append(comp.Sprite.new("run", run_png, 8, 48, 48, 3, true, 0, 15));
    try sprite_list.append(comp.Sprite.new("jump", jump_png, 6, 48, 48, 2, false, 0, 15));
    try sprite_list.append(comp.Sprite.new("punch", punch_png, 8, 64, 64, 3, false, -15, 0));
    try sprite_list.append(comp.Sprite.new("roll", roll_png, 7, 48, 48, 2, false, 0, 15));
    try sprite_list.append(comp.Sprite.new("dash", dash_png, 9, 48, 48, 4, false, 0, 15));
    try sprite_list.append(comp.Sprite.new("land", land_png, 9, 48, 48, 3, false, 0, 15));
    try sprite_list.append(comp.Sprite.new("crouch_idle", crouch_idle_png, 10, 48, 48, 3, true, 0, 15));
    try sprite_list.append(comp.Sprite.new("crouch_walk", crouch_walk_png, 10, 48, 48, 3, true, 0, 15));

    reg.add(entity, comp.Animate{ .sprites = try sprite_list.toOwnedSlice() });

    reg.add(entity, comp.PlayerTag{});
    reg.add(entity, comp.Gravity{});
}

test {
    _ = tests;
}
