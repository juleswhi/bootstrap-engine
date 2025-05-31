const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const serialiser = @import("../serializer.zig");
const debug = @import("../log.zig").debug;

pub fn animate(reg: *ecs.Registry, frame_counter: *u32) void {
    var view = reg.view(.{ comp.PlayerTag, comp.Animate }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate_comp = view.get(comp.Animate, e);
        if (frame_counter.* >= (60 / animate_comp.frame_speed)) {
            frame_counter.* = 0;
            switch (animate_comp.state) {
                .idle => |*frame| {
                    frame.* += 1;
                    if (frame.* > animate_comp.idle_frames - 1) {
                        frame.* = 0;
                    }
                    animate_comp.idle_rec.x = (toFloat(frame.*)) * (animate_comp.idle_rec.width);
                },
                .run => |*frame| {
                    frame.* += 1;
                    if (frame.* > animate_comp.run_frames - 1) {
                        frame.* = 0;
                    }
                    animate_comp.run_rec.x = (toFloat(frame.*)) * (animate_comp.run_rec.width);
                },
            }
        }
    }
}

pub fn loadTextures(reg: *ecs.Registry) !void {
    var view = reg.view(.{ comp.Animate, comp.PlayerTag }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate_comp = reg.get(comp.Animate, e);
        // Fix to use sentinal but cant be arsed
        animate_comp.idle_texture = try rl.loadTexture("assets/samurai/idle.png");
        animate_comp.run_texture = try rl.loadTexture("assets/samurai/run.png");
        animate_comp.idle_rec = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = toFloat(animate_comp.idle_texture.?.width) / toFloat(animate_comp.idle_frames),
            .height = toFloat(animate_comp.idle_texture.?.height),
        };
        animate_comp.run_rec = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = toFloat(animate_comp.run_texture.?.width) / toFloat(animate_comp.run_frames),
            .height = toFloat(animate_comp.run_texture.?.height),
        };
    }
}

pub fn unloadTextures(reg: *ecs.Registry) !void {
    var view = reg.view(.{ comp.Animate, comp.PlayerTag }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate_comp = reg.get(comp.Animate, e);
        rl.unloadTexture(animate_comp.idle_texture.?);
        rl.unloadTexture(animate_comp.run_texture.?);
    }
}

fn toFloat(x: anytype) f32 {
    return @floatFromInt(x);
}
