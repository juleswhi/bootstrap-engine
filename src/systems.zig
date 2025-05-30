const std = @import("std");
const ecs = @import("ecs");
const comp = @import("components/components.zig");
const rl = @import("raylib");
const Level = @import("level.zig").Level;
const serialiser = @import("serializer.zig");
const debug = @import("log.zig").debug;

pub fn inputSystem(reg: *ecs.Registry, dt: f32) !void {
    var view = reg.view(.{ comp.PlayerTag, comp.Velocity }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const vel = view.get(comp.Velocity, e);
        vel.x = 0;

        if (rl.isKeyDown(.right) or rl.isKeyDown(.d)) vel.x = 500;
        if (rl.isKeyDown(.left) or rl.isKeyDown(.a)) vel.x = -500;
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

        if (rl.isKeyDown(.space) or rl.isKeyDown(.up) or rl.isKeyDown(.w)) {
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
    const COLLIDER_TOLERANCE: f32 = 0.2;

    var collider_view = reg.view(.{
        comp.Position,
        comp.Size,
        comp.Velocity,
        comp.Grounded,
    }, .{});

    var ground_view = reg.view(.{
        comp.EnvironmentTag,
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

        // Horizontal collision pass FIRST
        var horizontal_ground_iter = ground_view.entityIterator();
        while (horizontal_ground_iter.next()) |ground_entity| {
            const ground_pos = ground_view.getConst(comp.Position, ground_entity);
            const ground_size = ground_view.getConst(comp.Size, ground_entity);
            const ground_rect = rl.Rectangle{
                .x = ground_pos.x,
                .y = ground_pos.y,
                .width = ground_size.width,
                .height = ground_size.height,
            };

            const collider_rect = rl.Rectangle{
                .x = collider_pos.x,
                .y = collider_pos.y,
                .width = collider_size.width,
                .height = collider_size.height,
            };

            if (!rl.checkCollisionRecs(collider_rect, ground_rect)) continue;

            // Calculate horizontal penetration from both sides
            const right_penetration = (collider_rect.x + collider_rect.width) - ground_rect.x;
            const left_penetration = (ground_rect.x + ground_rect.width) - collider_rect.x;

            // Collision with left side of ground (collider moving right)
            if (right_penetration > 0 and
                right_penetration <= collider_rect.width and
                collider_vel.x > 0)
            {
                collider_pos.x -= right_penetration;
                collider_vel.x = 0;
            }
            // Collision with right side of ground (collider moving left)
            else if (left_penetration > 0 and
                left_penetration <= collider_rect.width and
                collider_vel.x < 0)
            {
                collider_pos.x += left_penetration;
                collider_vel.x = 0;
            }
        }

        // Vertical collision pass SECOND
        var vertical_ground_iter = ground_view.entityIterator();
        while (vertical_ground_iter.next()) |ground_entity| {
            const ground_pos = ground_view.getConst(comp.Position, ground_entity);
            const ground_size = ground_view.getConst(comp.Size, ground_entity);
            const ground_rect = rl.Rectangle{
                .x = ground_pos.x,
                .y = ground_pos.y,
                .width = ground_size.width,
                .height = ground_size.height,
            };

            const collider_rect = rl.Rectangle{
                .x = collider_pos.x,
                .y = collider_pos.y,
                .width = collider_size.width,
                .height = collider_size.height,
            };

            if (!rl.checkCollisionRecs(collider_rect, ground_rect)) continue;

            // Calculate vertical penetration from top
            const collider_bottom = collider_rect.y + collider_rect.height;
            const ground_top = ground_rect.y;
            const vertical_penetration = collider_bottom - ground_top;

            // Only resolve collision if player is falling and penetration is reasonable
            if (vertical_penetration >= -COLLIDER_TOLERANCE and
                vertical_penetration <= collider_rect.height + COLLIDER_TOLERANCE and
                collider_vel.y >= 0)
            {
                collider_pos.y -= vertical_penetration;
                collider_vel.y = 0;
                collider_grounded.value = true;
                // Break after first vertical collision to prevent multiple adjustments
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
    // renderGrounded(reg);
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
