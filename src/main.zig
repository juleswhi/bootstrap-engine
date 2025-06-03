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
const Debug = @import("components/debug.zig").Debug;

pub fn main() !void {
    var args = std.process.args();
    while (args.next()) |arg| {
        debug("Arg: {s}", .{arg});
        if (std.mem.eql(u8, "debug", arg)) {
            Debug.active = true;
        }
        if (std.mem.eql(u8, "all", arg)) {
            Debug.all = true;
        }
    }

    var reg = ecs.Registry.init(std.heap.page_allocator);

    const width = 1500;
    const height = 800;

    try createPlayer(&reg, width, height);

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

fn createPlayer(reg: *ecs.Registry, width: f32, _: f32) !void {
    const entity = reg.create();

    reg.add(entity, comp.Hitbox.new(width / 2, 10, 48, 48));
    reg.add(entity, comp.Canvas{ .width = 96, .height = 96 });

    reg.add(entity, comp.Jump{});
    reg.add(entity, comp.Velocity.new(0, 0));
    reg.add(entity, comp.Grounded{});
    reg.add(entity, comp.Crouch{});

    reg.add(entity, comp.Dodge{ .speed = 1500 });

    var sprite_list = std.ArrayList(comp.Sprite).init(std.heap.page_allocator);
    try sprite_list.append(comp.Sprite.new("idle", "assets/rain/idle.png", 10, 48, 48, 2, true, 0, 15));
    try sprite_list.append(comp.Sprite.new("run", "assets/rain/run.png", 8, 48, 48, 3, true, 0, 15));
    try sprite_list.append(comp.Sprite.new("jump", "assets/rain/jump.png", 6, 48, 48, 2, false, 0, 15));
    try sprite_list.append(comp.Sprite.new("punch", "assets/rain/punch.png", 8, 64, 64, 3, false, -15, 0));
    try sprite_list.append(comp.Sprite.new("roll", "assets/rain/roll.png", 7, 48, 48, 2, false, 0, 15));
    try sprite_list.append(comp.Sprite.new("dash", "assets/rain/dash.png", 9, 48, 48, 4, false, 0, 15));
    try sprite_list.append(comp.Sprite.new("land", "assets/rain/land.png", 9, 48, 48, 3, false, 0, 15));
    try sprite_list.append(comp.Sprite.new("crouch_idle", "assets/rain/crouch-idle.png", 10, 48, 48, 3, true, 0, 15));
    try sprite_list.append(comp.Sprite.new("crouch_walk", "assets/rain/crouch-walk.png", 10, 48, 48, 3, true, 0, 15));

    reg.add(entity, comp.Animate{ .sprites = try sprite_list.toOwnedSlice() });

    reg.add(entity, comp.PlayerTag{});
    reg.add(entity, comp.Gravity{});
}

test {
    _ = tests;
}
