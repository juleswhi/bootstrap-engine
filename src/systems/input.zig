const std = @import("std");
const ecs = @import("ecs");
const comp = @import("../components/components.zig");
const rl = @import("raylib");
const serialiser = @import("../serializer.zig");
const sd = @import("../log.zig");

// TODO: mkae json file
// TODO: lerp
// TODO: Variable jump height
pub fn input(reg: *ecs.Registry, dt: f32) !void {
    var view = reg.view(.{ comp.Hitbox, comp.Velocity, comp.Dodge }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const vel = view.get(comp.Velocity, e);
        var dodge = view.get(comp.Dodge, e);
        var hitbox = view.get(comp.Hitbox, e);
        var gravity = view.get(comp.Gravity, e);
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

        if (rl.isKeyDown(.s) or rl.isKeyDown(.down)) {
            if (reg.has(comp.Crouch, e)) {
                const crouch = reg.get(comp.Crouch, e);
                crouch.active = true;
            }
        } else {
            if (reg.has(comp.Crouch, e)) {
                const crouch = reg.get(comp.Crouch, e);
                crouch.active = false;
            }
        }

        if (rl.isMouseButtonDown(.left)) {
            gravity.enabled = false;
            hitbox.x = toFloat(rl.getMouseX());
            hitbox.y = toFloat(rl.getMouseY());
        } else {
            gravity.enabled = true;
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
        const json = @embedFile("..\\levels\\level_one.json");
        sd.debug("{s}", .{json});

        var level = try serialiser.deserialiseLevel(json);
        defer std.heap.page_allocator.free(level.rects);

        level.load(reg);
    }
    if (rl.isKeyPressed(.two)) {
        const json = @embedFile("..\\levels\\level_two.json");
        sd.debug("{s}", .{json});

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
    const JUMP_BUFFER = 0.05;
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

        if (grounded.value) {
            jump.coyote_time = COYOTE_TIME;
            jump.is_jumping = false;
        } else {
            jump.coyote_time -= dt;
        }

        jump.can_jump = grounded.value or jump.coyote_time > 0;

        if (rl.isKeyDown(.space) or rl.isKeyDown(.up) or rl.isKeyDown(.w)) {
            jump.buffer_time = JUMP_BUFFER;
        }

        if (jump.buffer_time > 0 and jump.can_jump) {
            vel.y = -jump.initial_velocity;
            jump.buffer_time = 0;
            jump.coyote_time = 0;
            jump.is_jumping = true;
        } else {
            jump.buffer_time = @max(0, jump.buffer_time - dt);
        }

        if (jump.is_jumping and vel.y < 0) {
            const jumpKeyReleased =
                !rl.isKeyDown(.space) and
                !rl.isKeyDown(.up) and
                !rl.isKeyDown(.w);
            if (jumpKeyReleased) {
                vel.y *= 0.6;
                jump.is_jumping = false;
            }
        } else if (jump.is_jumping and vel.y >= 0) {
            jump.is_jumping = false;
        }
    }
}

fn toFloat(x: anytype) f32 {
    return @floatFromInt(x);
}
