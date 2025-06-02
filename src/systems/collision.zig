const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const serialiser = @import("../serializer.zig");
const debug = @import("../log.zig").debug;

// TODO: Refactor
pub fn collision(reg: *ecs.Registry) void {
    const COLLIDER_TOLERANCE: f32 = 0.2;
    var ground_view = reg.view(.{ comp.Environment, comp.Hitbox, comp.Colour }, .{});

    var collider_view = reg.view(.{ comp.Hitbox, comp.Velocity, comp.Grounded }, .{});
    var collider_iter = collider_view.entityIterator();

    while (collider_iter.next()) |collider_entity| {
        var collider_grounded = collider_view.get(comp.Grounded, collider_entity);
        collider_grounded.value = false;

        var collider_hitbox = collider_view.get(comp.Hitbox, collider_entity);
        var collider_vel = collider_view.get(comp.Velocity, collider_entity);

        if (comp.Debug.active) {
            debug("Hitbox: {}", .{collider_hitbox.toIntRect()});
            debug("Velocity: {}", .{collider_vel.toInt()});
        }

        var horizontal_ground_iter = ground_view.entityIterator();
        while (horizontal_ground_iter.next()) |ground_entity| {
            const ground_hitbox = ground_view.getConst(comp.Hitbox, ground_entity);

            const ground_rect = ground_hitbox.toRect();
            const collider_rect = collider_hitbox.toRect();

            if (!rl.checkCollisionRecs(collider_rect, ground_rect)) continue;

            const right_penetration = (collider_rect.x + collider_rect.width) - ground_rect.x;
            const left_penetration = (ground_rect.x + ground_rect.width) - collider_rect.x;

            if (right_penetration > 0 and
                right_penetration <= collider_rect.width and
                collider_vel.x > 0)
            {
                collider_hitbox.x -= right_penetration;
                collider_vel.x = 0;
            } else if (left_penetration > 0 and
                left_penetration <= collider_rect.width and
                collider_vel.x < 0)
            {
                collider_hitbox.x += left_penetration;
                collider_vel.x = 0;
            }
        }

        var vertical_ground_iter = ground_view.entityIterator();
        while (vertical_ground_iter.next()) |ground_entity| {
            var ground_hitbox = ground_view.getConst(comp.Hitbox, ground_entity);

            const ground_rect = ground_hitbox.toRect();
            const collider_rect = collider_hitbox.toRect();

            if (!rl.checkCollisionRecs(collider_rect, ground_rect)) continue;

            const collider_bottom = collider_rect.y + collider_rect.height;
            const ground_top = ground_rect.y;
            const vertical_penetration = collider_bottom - ground_top;

            if (vertical_penetration >= -COLLIDER_TOLERANCE and
                vertical_penetration <= collider_rect.height + COLLIDER_TOLERANCE and
                collider_vel.y >= 0)
            {
                collider_hitbox.y -= vertical_penetration;
                collider_vel.y = 0;
                collider_grounded.value = true;
                break;
            }
        }
    }
}
