const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const sd = @import("stardust");

pub fn movement(reg: *ecs.Registry, dt: f32) void {
    var view = reg.view(.{ comp.Hitbox, comp.Velocity }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const vel = view.getConst(comp.Velocity, e);
        var hitbox = view.get(comp.Hitbox, e);

        const crouch = reg.tryGet(comp.Crouch, e);

        if (crouch) |c| {
            if (c.active) {
                hitbox.x += vel.x * dt * 0.5;
                hitbox.y += vel.y * dt;
                continue;
            }
        }

        hitbox.x += vel.x * dt;
        hitbox.y += vel.y * dt;
    }

    var player_view = reg.view(.{ comp.Hitbox, comp.Velocity, comp.Animate, comp.Dodge, comp.Crouch }, .{});
    var player_iter = player_view.entityIterator();
    while (player_iter.next()) |e| {
        const vel = view.getConst(comp.Velocity, e);
        const dodge = view.getConst(comp.Dodge, e);
        const crouch = view.getConst(comp.Crouch, e);
        var ani = view.get(comp.Animate, e);

        if (ani.type == .punch or ani.type == .dash) {} else if (vel.y == 0 and dodge.is_dodging) {
            // ani.set_animation(.dash);
        } else if (vel.x == 0 and vel.y == 0 and !crouch.active and ani.type != .land) {
            ani.set_animation(.idle);
        } else if (vel.x == 0 and vel.y == 0 and crouch.active) {
            ani.set_animation(.crouch_idle);
        } else if (vel.x != 0 and vel.y == 0 and !crouch.active) {
            ani.set_animation(.run);
        } else if (vel.x != 0 and vel.y == 0 and crouch.active) {
            ani.set_animation(.crouch_walk);
        } else if (vel.y < 0 or vel.y > 20) {
            ani.set_animation(.jump);
        }

        if (vel.y < 20 and vel.y > -20 and rl.isKeyPressed(.f)) {
            ani.set_animation(.punch);
        }

        if (vel.x > 0) {
            ani.direction = 1;
        } else if (vel.x < 0) {
            ani.direction = -1;
        }
    }
}
