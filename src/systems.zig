const std = @import("std");
const ecs = @import("ecs");
const comp = @import("components/components.zig");
const rl = @import("raylib");

pub fn inputSystem(reg: *ecs.Registry, dt: f32) void {
    var view = reg.view(.{ comp.PlayerTag, comp.Velocity }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const vel = view.get(comp.Velocity, e);
        vel.x = 0;

        if (rl.isKeyDown(.right)) vel.x = 500;
        if (rl.isKeyDown(.left)) vel.x = -500;
    }

    jumpInputSystem(reg, dt);
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

        if (rl.isKeyDown(.space) or rl.isKeyDown(.up)) {
            jump.buffer_time = JUMP_BUFFER;
        }

        if (jump.buffer_time > 0 and jump.can_jump) {
            vel.y = -500;
            jump.buffer_time = 0;
            jump.coyote_time = 0;
        } else {
            jump.buffer_time = @max(0, jump.buffer_time - dt);
        }
    }
}

pub fn movementSystem(reg: *ecs.Registry, dt: f32) void {
    var view = reg.view(.{ comp.Position, comp.Velocity }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const vel = view.getConst(comp.Velocity, e);
        var pos = view.get(comp.Position, e);
        pos.x += vel.x * dt;
        pos.y += vel.y * dt;
    }
}

const GRAVITY_ACCEL = 2000;

pub fn collisionSystem(reg: *ecs.Registry) void {
    const COLLIDER_TOLERANCE: f32 = 0.1;

    var collider_view = reg.view(.{
        comp.Position,
        comp.Size,
        comp.Velocity,
        comp.Grounded,
    }, .{});

    var ground_view = reg.view(.{
        comp.GroundTag,
        comp.Position,
        comp.Size,
    }, .{});

    var collider_iter = collider_view.entityIterator();

    while (collider_iter.next()) |collider_entity| {
        var collider_grounded = collider_view.get(comp.Grounded, collider_entity);
        collider_grounded.value = false;

        var collider_pos = collider_view.get(comp.Position, collider_entity);
        const collider_size = collider_view.getConst(comp.Size, collider_entity);
        var collider_vel = collider_view.get(comp.Velocity, collider_entity);

        const collider_rect = rl.Rectangle{
            .x = collider_pos.x,
            .y = collider_pos.y,
            .width = collider_size.width,
            .height = collider_size.height,
        };

        var ground_iter = ground_view.entityIterator();
        while (ground_iter.next()) |ground_entity| {
            const ground_pos = ground_view.getConst(comp.Position, ground_entity);
            const ground_size = ground_view.getConst(comp.Size, ground_entity);
            const ground_rect = rl.Rectangle{
                .x = ground_pos.x,
                .y = ground_pos.y,
                .width = ground_size.width,
                .height = ground_size.height,
            };

            if (!rl.checkCollisionRecs(collider_rect, ground_rect)) continue;

            const collider_bottom = collider_rect.y + collider_rect.height;
            const ground_top = ground_rect.y;
            const penetration = collider_bottom - ground_top;

            if (penetration >= -COLLIDER_TOLERANCE and
                penetration <= collider_rect.height + COLLIDER_TOLERANCE and
                collider_vel.y >= 0)
            {
                collider_pos.y -= penetration;
                collider_vel.y = 0;
                collider_grounded.value = true;
                break;
            }
        }
    }
}

pub fn gravitySystem(reg: *ecs.Registry, dt: f32) void {
    var view = reg.view(.{ comp.GravityTag, comp.Velocity, comp.Grounded }, .{});
    var iter = view.entityIterator();

    while (iter.next()) |e| {
        const grounded = view.getConst(comp.Grounded, e);
        if (grounded.value) continue;

        var vel = view.get(comp.Velocity, e);
        vel.y += GRAVITY_ACCEL * dt;
    }
}

pub fn renderSystem(reg: *ecs.Registry) void {
    renderGrounded(reg);
    var view = reg.view(.{ comp.RenderTag, comp.Position, comp.Size, comp.Colour }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const pos = view.getConst(comp.Position, e);
        const size = view.getConst(comp.Size, e);
        const color = view.getConst(comp.Colour, e);
        const rl_colour = color.toRaylib();

        rl.drawRectangle(toInt(pos.x), toInt(pos.y), toInt(size.width), toInt(size.height), rl_colour);
    }
}

fn renderGrounded(reg: *ecs.Registry) void {
    var view = reg.view(.{ comp.PlayerTag, comp.Grounded }, .{});
    var iter = view.entityIterator();

    while (iter.next()) |e| {
        const grounded = view.getConst(comp.Grounded, e);
        const text = if (grounded.value) "Grounded" else "Airborne";
        rl.drawText(text, 10, 10, 40, .white);
    }
}

fn toInt(f: f32) i32 {
    return @intFromFloat(f);
}
