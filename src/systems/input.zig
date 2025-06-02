const std = @import("std");
const ecs = @import("ecs");
const comp = @import("../components/components.zig");
const rl = @import("raylib");
const serialiser = @import("../serializer.zig");
const debug = @import("../log.zig").debug;

// mkae json file
pub fn input(reg: *ecs.Registry, dt: f32) !void {
    var view = reg.view(.{ comp.PlayerTag, comp.Velocity, comp.Dodge }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const vel = view.get(comp.Velocity, e);
        var dodge = view.get(comp.Dodge, e);
        const prev_vel = vel.x;
        vel.x = 0;

        if (rl.isKeyDown(.right) or rl.isKeyDown(.d)) {
            vel.x = @max(500, @abs(prev_vel));
            if (dodge.is_dodging and dodge.direction != 1) {
                dodge.is_dodging = false;
                vel.x = 0;
            }
        }
        if (rl.isKeyDown(.left) or rl.isKeyDown(.a)) {
            vel.x = -1 * @max(500, @abs(prev_vel));
            if (dodge.is_dodging and dodge.direction != -1) {
                dodge.is_dodging = false;
                dodge.cooldown_timer = dodge.cooldown;
                vel.x = 0;
            }
        }
    }

    try levelInputSystem(reg);
    dodgeInputSystem(reg);
    jumpInputSystem(reg, dt);
    overlayInputSystem();
}

fn overlayInputSystem() void {
    if (rl.isKeyPressed(.o)) {
        comp.Debug.toggle();
    }
}

fn levelInputSystem(reg: *ecs.Registry) !void {
    if (rl.isKeyPressed(.one)) {
        const json = try serialiser.readJsonFile(std.heap.page_allocator, "levels/level_one.json");
        defer std.heap.page_allocator.free(json);

        debug("{s}", .{json});

        var level = try serialiser.deserialiseLevel(json);
        defer std.heap.page_allocator.free(level.rects);

        level.load(reg);
    }
    if (rl.isKeyPressed(.two)) {
        const json = try serialiser.readJsonFile(std.heap.page_allocator, "levels/level_two.json");
        defer std.heap.page_allocator.free(json);

        debug("{s}", .{json});

        var level = try serialiser.deserialiseLevel(json);
        defer std.heap.page_allocator.free(level.rects);

        level.load(reg);
    }
}

fn dodgeInputSystem(reg: *ecs.Registry) void {
    var view = reg.view(.{ comp.PlayerTag, comp.Velocity, comp.Dodge }, .{});
    var iter = view.entityIterator();

    while (iter.next()) |e| {
        var dodge = view.get(comp.Dodge, e);

        if (dodge.cooldown_timer > 0 or dodge.is_dodging) continue;
        if (!rl.isKeyPressed(.left_shift)) continue;

        if (rl.isKeyDown(.right) or rl.isKeyDown(.d)) {
            dodge.is_dodging = true;
            dodge.direction = 1;
            dodge.remaining_time = dodge.duration;
        } else if (rl.isKeyDown(.left) or rl.isKeyDown(.a)) {
            dodge.is_dodging = true;
            dodge.direction = -1;
            dodge.remaining_time = dodge.duration;
        }
    }
}

fn jumpInputSystem(reg: *ecs.Registry, dt: f32) void {
    const JUMP_BUFFER = 0.1;
    const COYOTE_TIME = 0.1;

    var view = reg.view(.{
        comp.PlayerTag,
        comp.Velocity,
        comp.Grounded,
        comp.Jump,
    }, .{});

    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const grounded = view.getConst(comp.Grounded, e);
        var vel = view.get(comp.Velocity, e);
        var jump = view.get(comp.Jump, e);

        jump.can_jump = grounded.value or jump.coyote_time > 0;

        if (grounded.value) {
            jump.coyote_time = COYOTE_TIME;
        } else {
            jump.coyote_time -= dt;
        }

        if (rl.isKeyDown(.space) or rl.isKeyDown(.up) or rl.isKeyDown(.w)) {
            jump.buffer_time = JUMP_BUFFER;
        }

        if (jump.buffer_time > 0 and jump.can_jump) {
            vel.y = -650;
            jump.buffer_time = 0;
            jump.coyote_time = 0;
        } else {
            jump.buffer_time = @max(0, jump.buffer_time - dt);
        }
    }
}
