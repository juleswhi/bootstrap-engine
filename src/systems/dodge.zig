const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const serialiser = @import("../serializer.zig");
const debug = @import("../log.zig").debug;

pub fn dodge(reg: *ecs.Registry, dt: f32) void {
    var view = reg.view(.{ comp.Velocity, comp.Dodge, comp.Colour, comp.Size }, .{});
    var iter = view.entityIterator();

    while (iter.next()) |e| {
        var vel = view.get(comp.Velocity, e);
        var dodge_comp = view.get(comp.Dodge, e);
        var col = view.get(comp.Colour, e);

        if (dodge_comp.is_dodging) {
            const progress = (dodge_comp.remaining_time / dodge_comp.duration);

            col.a = 100;
            vel.x = dodge_comp.direction * @max((dodge_comp.speed * progress), 500);
            dodge_comp.remaining_time -= dt;

            if (dodge_comp.remaining_time <= 0) {
                dodge_comp.is_dodging = false;
                dodge_comp.cooldown_timer = dodge_comp.cooldown;
            }

        } else if (dodge_comp.cooldown_timer > 0) {
            col.a = 175;
            vel.x = sign(vel.x) * @min(@abs(vel.x), 500);
            dodge_comp.cooldown_timer -= dt;
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
