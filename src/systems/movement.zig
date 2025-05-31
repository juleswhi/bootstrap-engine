const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const serialiser = @import("../serializer.zig");
const debug = @import("../log.zig").debug;

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
