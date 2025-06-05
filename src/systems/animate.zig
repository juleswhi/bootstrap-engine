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

        if (comp.Debug.all) {
            sd.debug("Accumulator: {d}, dt: {d}", .{ sprite.accumulator, dt });
        }

        const time_per_frame = 1.0 / @as(f32, @floatFromInt(sprite.frame_speed));

        if (comp.Debug.all) {
            sd.err("Frame Speed: {d}, Time per frame: {d}", .{ sprite.frame_speed, time_per_frame });
        }

        while (sprite.accumulator >= time_per_frame) {
            if (comp.Debug.all) {
                sd.debug("Accumulator is: {d}, more than time_per_frame: {d}", .{ sprite.accumulator, time_per_frame });
            }

            sprite.accumulator -= time_per_frame;

            if (sprite.current_frame < toFloat(sprite.show_frames)) {
                sd.debug("Still need to update animation, current frame is: {d}", .{sprite.current_frame});
                sprite.current_frame += 1;
            }

            if (comp.Debug.active) {
                sd.debug("Current Frame: {}, Num Frames: {}", .{ toInt(sprite.current_frame), sprite.num_frames - 1 });
            }

            // TODO: Fix this terrible mess
            if (sprite.current_frame > toFloat(sprite.show_frames - 1)) {
                if (!sprite.looping) {
                    sd.debug("Not looping, stopping animation", .{});
                    if (animate_comp.type == .jump) {
                        sd.debug("Current animation is jump", .{});
                        if (reg.has(comp.Velocity, e)) {
                            const vel = reg.get(comp.Velocity, e);
                            if (vel.y == 0) {
                                animate_comp.set_animation(.land);
                            }
                        }
                    } else if (animate_comp.type == .land or animate_comp.type == animate_comp.previous_type) {
                        sd.debug("new animation is: idle", .{});
                        animate_comp.set_animation(.idle);
                    } else {
                        sd.debug("new animation is: {}", .{animate_comp.type});
                        animate_comp.set_animation(animate_comp.previous_type);
                    }
                } else {
                    sd.debug("setting animation frame back to zero", .{});
                    sprite.current_frame = 0;
                }
            }
        }

        // sd.debug("Current frame: {d}", .{sprite.current_frame});

        sprite.rectangle.x =
            (sprite.current_frame * (toFloat(sprite.texture.?.width) / toFloat(sprite.num_frames)));
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
