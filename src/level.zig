const std = @import("std");
const ecs = @import("ecs");
const comp = @import("components/components.zig");
const log = @import("log.zig");
const json = std.json;

pub const LevelRectangle = struct {
    hitbox: comp.Hitbox,
    colour: comp.Colour = comp.Colour.new(0, 255, 0, 255),
    render: bool = false,
};

pub const Level = struct {
    name: []const u8,
    start_x: i32,
    start_y: i32,
    rects: []LevelRectangle,

    pub fn free(level: *Level) void {
        std.heap.page_allocator.free(level.rects);
    }

    pub fn load(level: *Level, reg: *ecs.Registry) void {
        var old_view = reg.view(.{comp.Hitbox}, .{comp.PlayerTag});
        var old_iter = old_view.entityIterator();
        while (old_iter.next()) |e| {
            reg.destroy(e);
        }

        var level_view = reg.view(.{comp.LevelTag}, .{});
        var level_iter = level_view.entityIterator();
        while (level_iter.next()) |e| {
            reg.destroy(e);
        }

        var player_view = reg.view(.{ comp.PlayerTag, comp.Hitbox, comp.Velocity }, .{});
        var player_iter = player_view.entityIterator();
        while (player_iter.next()) |e| {
            var pos = reg.get(comp.Hitbox, e);
            var vel = reg.get(comp.Velocity, e);
            pos.x = toFloat(level.start_x);
            pos.y = toFloat(level.start_y);
            vel.x = 0;
            vel.y = 0;

            level.add_ecs(reg);
        }
    }

    pub fn add_ecs(level: *Level, reg: *ecs.Registry) void {
        const level_entity = reg.create();
        reg.add(level_entity, comp.LevelTag{ .level = level });
        for (level.rects) |rect| {
            const e = reg.create();
            reg.add(e, rect.colour);
            reg.add(e, rect.hitbox);
            reg.add(e, comp.Environment{ .render = rect.render });
        }
    }
};

fn toInt(f: f32) i32 {
    return @intFromFloat(f);
}

fn toFloat(i: i32) f32 {
    return @floatFromInt(i);
}
