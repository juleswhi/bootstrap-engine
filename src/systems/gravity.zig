const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const serialiser = @import("../serializer.zig");
const debug = @import("../log.zig").debug;

const GRAVITY_ACCEL = 2000;

pub fn gravity(reg: *ecs.Registry, dt: f32) void {
    var view = reg.view(.{ comp.Gravity, comp.Velocity, comp.Grounded }, .{});
    var iter = view.entityIterator();

    while (iter.next()) |e| {
        const grounded = view.getConst(comp.Grounded, e);
        if (grounded.value) continue;

        if (comp.Debug.active) {
            debug("Gravity Active, Grounded: {}", .{grounded.value});
        }

        var vel = view.get(comp.Velocity, e);
        vel.y += GRAVITY_ACCEL * dt;
    }
}
