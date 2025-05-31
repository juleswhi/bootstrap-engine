const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const serialiser = @import("../serializer.zig");
const debug = @import("../log.zig").debug;

pub fn dodgeSystem(reg: *ecs.Registry, dt: f32) void {
    var view = reg.view(.{ comp.Velocity, comp.Dodge, comp.Colour, comp.Size }, .{});
    var iter = view.entityIterator();

    while (iter.next()) |e| {
        var vel = view.get(comp.Velocity, e);
        var dodge = view.get(comp.Dodge, e);
        var col = view.get(comp.Colour, e);

        if (dodge.is_dodging) {
            const progress = (dodge.remaining_time / dodge.duration);

            col.a = 100;
            vel.x = dodge.direction * @max((dodge.speed * progress), 500);
            dodge.remaining_time -= dt;

            if (dodge.remaining_time <= 0) {
                dodge.is_dodging = false;
                dodge.cooldown_timer = dodge.cooldown;
            }

        } else if (dodge.cooldown_timer > 0) {
            col.a = 175;
            vel.x = sign(vel.x) * @min(@abs(vel.x), 500);
            dodge.cooldown_timer -= dt;
        } else {
            col.a = 255;
        }
    }
}

fn sign(n: anytype) f32 {
    if(n > 0) return 1;
    if(n < 0) return -1;
    return 0;
}
