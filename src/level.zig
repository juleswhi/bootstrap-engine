const std = @import("std");
const ecs = @import("ecs");
const comp = @import("components/components.zig");
const serialiser = @import("serializer.zig");
const sd = @import("log.zig");
const json = std.json;

pub const LevelRectangle = struct {
    hitbox: comp.Hitbox,
    colour: comp.Colour = comp.Colour.new(166, 151, 156, 255),
    render: bool = false,
};

pub fn saveLevel(rects: *std.ArrayList(LevelRectangle), name: []const u8) !void {
    var level = Level{
        .rects = try rects.toOwnedSlice(),
        .name = name,
        .start_x = 500,
        .start_y = 100,
    };

    const json_str = try serialiser.serialiseLevel(&level);
    defer std.heap.page_allocator.free(json_str);
    sd.debug("{s}\n", .{json_str});
    try serialiser.writeJsonFile("src/levels/level_three.json", json_str);
}

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
