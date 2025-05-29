const std = @import("std");
const ecs = @import("ecs");
const comp = @import("components/components.zig");
const rl = @import("raylib");

pub fn inputSystem(reg: *ecs.Registry) void {
    var view = reg.view(.{ comp.PlayerTag, comp.Velocity}, .{});
    var iter = view.entityIterator();
    while(iter.next()) |e| {
        const vel = view.get(comp.Velocity, e);
        vel.x = 0;

        if(rl.isKeyDown(.right)) vel.x = 500;
        if(rl.isKeyDown(.left)) vel.x = -500;
    }
}

pub fn movementSystem(reg: *ecs.Registry, dt: f32) void {
    var view = reg.view(.{comp.Position, comp.Velocity}, .{});
    var iter = view.entityIterator();
    while(iter.next()) |e| {
        const vel = view.getConst(comp.Velocity, e);
        var pos = view.get(comp.Position, e);
        pos.x += vel.x * dt;
        pos.y += vel.y * dt;
    }
}

pub fn renderSystem(reg: *ecs.Registry) void {
    var view = reg.view(.{comp.Position, comp.Size, comp.Colour}, .{});
    var iter = view.entityIterator();
    while(iter.next()) |e| {
        const pos = view.getConst(comp.Position, e);
        const size = view.getConst(comp.Size, e);
        const color = view.getConst(comp.Colour, e);
        const rl_colour = color.toRaylib();

        rl.drawRectangle(toInt(pos.x), toInt(pos.y), toInt(size.width), toInt(size.height), rl_colour);
    }
}

fn toInt(f: f32) i32 {
    return @intFromFloat(f);
}
