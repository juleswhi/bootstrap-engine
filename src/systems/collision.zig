const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const serialiser = @import("../serializer.zig");
const debug = @import("../log.zig").debug;

pub fn collision(reg: *ecs.Registry) void {
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

            const right_penetration = (collider_rect.x + collider_rect.width) - ground_rect.x;
            const left_penetration = (ground_rect.x + ground_rect.width) - collider_rect.x;

            if (right_penetration > 0 and
                right_penetration <= collider_rect.width and
                collider_vel.x > 0)
            {
                collider_pos.x -= right_penetration;
                collider_vel.x = 0;
            }

            else if (left_penetration > 0 and
                left_penetration <= collider_rect.width and
                collider_vel.x < 0)
            {
                collider_pos.x += left_penetration;
                collider_vel.x = 0;
            }
        }

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

            const collider_bottom = collider_rect.y + collider_rect.height;
            const ground_top = ground_rect.y;
            const vertical_penetration = collider_bottom - ground_top;

            if (vertical_penetration >= -COLLIDER_TOLERANCE and
                vertical_penetration <= collider_rect.height + COLLIDER_TOLERANCE and
                collider_vel.y >= 0)
            {
                collider_pos.y -= vertical_penetration;
                collider_vel.y = 0;
                collider_grounded.value = true;
                break;
            }
        }
    }
}

