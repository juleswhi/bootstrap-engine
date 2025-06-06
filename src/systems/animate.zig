const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const sd = @import("../log.zig");
const FPS = @import("../main.zig").FPS;

pub fn animate(reg: *ecs.Registry, dt: f32) void {
    var view = reg.view(.{ comp.PlayerTag, comp.Animate }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate_comp = view.get(comp.Animate, e);
        var sprite = animate_comp.get_sprite();

        sprite.accumulator += dt;
        const time_per_frame = 1.0 / @as(f32, @floatFromInt(sprite.frame_speed));

        if (sprite.accumulator < time_per_frame) continue;

        sprite.accumulator -= time_per_frame;

        if (sprite.current_frame < toFloat(sprite.num_frames - 1)) {
            sprite.current_frame += 1;
            break;
        }

        if (sprite.looping) {
            sprite.current_frame = 0;
            break;
        }

        if (sprite.next) |next| {
            if (animate_comp.type == .jump) {
                const vel = reg.get(comp.Velocity, e);
                if (vel.y == 0) {
                    animate_comp.set_animation(next);
                }
            } else {
                animate_comp.set_animation(next);
            }
            break;
        }
        animate_comp.set_animation(.idle);
    }
}

pub fn loadTextures(reg: *ecs.Registry) !void {
    var view = reg.view(.{ comp.Animate, comp.PlayerTag }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate_comp = reg.get(comp.Animate, e);

        for (animate_comp.sprites) |*s| {
            const image = try rl.loadImageFromMemory(".png", s.image_data);
            defer rl.unloadImage(image);

            s.texture = try rl.loadTextureFromImage(image);
            sd.info("Loaded texture for: {s}", .{s.name});

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
