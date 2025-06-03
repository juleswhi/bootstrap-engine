const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const serialiser = @import("../serializer.zig");
const sd = @import("stardust");
const FPS = @import("../main.zig").FPS;

pub fn animate(reg: *ecs.Registry, frame_counter: *u32) void {
    var view = reg.view(.{ comp.PlayerTag, comp.Animate }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate_comp = view.get(comp.Animate, e);
        var sprite = animate_comp.get_sprite();

        if (!(frame_counter.* >= toInt(((toFloat(FPS) / 5) / toFloat(sprite.frame_speed))))) continue;
        frame_counter.* = 0;

        sprite.current_frame += 1;

        if (comp.Debug.all) {
            sd.debug("Current Frame: {}, Num Frames: {}", .{ toInt(sprite.current_frame), sprite.num_frames - 1 });
        }
        if (sprite.current_frame > toFloat(sprite.num_frames - 2)) {
            if (!sprite.looping) {
                if(animate_comp.type == .land) {
                    animate_comp.set_animation(.idle);
                } else {
                    animate_comp.set_animation(animate_comp.previous_type);
                }
                continue;
            }
        }

        if (sprite.current_frame > toFloat(sprite.num_frames - 1)) {
            sprite.current_frame = 0;
        }

        sprite.rectangle.x =
            (sprite.current_frame * (toFloat(sprite.texture.?.width) / toFloat(sprite.num_frames)) + (sprite.rectangle.width));
    }
}

pub fn loadTextures(reg: *ecs.Registry) !void {
    var view = reg.view(.{ comp.Animate, comp.PlayerTag }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate_comp = reg.get(comp.Animate, e);

        for (animate_comp.sprites) |*s| {
            s.texture = try rl.loadTexture(s.texture_path);
            sd.info("Unloaded texture for: {s}", .{s.name});

            s.rectangle = rl.Rectangle{
                .x = 0,
                .y = toFloat(s.texture.?.height) - toFloat(s.height),
                .width = toFloat(s.width),
                .height = toFloat(s.height),
            };
        }
    }
}

pub fn unloadTextures(reg: *ecs.Registry) !void {
    var view = reg.view(.{ comp.Animate, comp.PlayerTag }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate_comp = reg.get(comp.Animate, e);

        for (animate_comp.sprites) |*s| {
            rl.unloadTexture(s.texture.?);
            sd.info("Unloaded texture for: {s}", .{s.name});
        }
    }
}

fn toFloat(x: anytype) f32 {
    return @floatFromInt(x);
}
fn toInt(x: anytype) i32 {
    return @intFromFloat(x);
}
