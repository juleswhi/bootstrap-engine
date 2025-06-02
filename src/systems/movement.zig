const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const serialiser = @import("../serializer.zig");
const debug = @import("../log.zig").debug;

pub fn movement(reg: *ecs.Registry, dt: f32) void {
    var view = reg.view(.{ comp.Hitbox, comp.Velocity }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const vel = view.getConst(comp.Velocity, e);
        var hitbox = view.get(comp.Hitbox, e);

        hitbox.x += vel.x * dt;
        hitbox.y += vel.y * dt;
    }

    var player_view = reg.view(.{ comp.Hitbox, comp.Velocity, comp.Animate }, .{});
    var player_iter = player_view.entityIterator();
    while (player_iter.next()) |e| {
        const vel = view.getConst(comp.Velocity, e);
        var ani = view.get(comp.Animate, e);

        if (vel.x == 0) {
            ani.type = .idle;
        } else if (vel.x < 0) {
            ani.type = .run;
            ani.direction = -1;
        } else if (vel.x > 0) {
            ani.type = .run;
            ani.direction = 1;
        }
    }
}
