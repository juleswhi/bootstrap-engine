const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const serialiser = @import("../serializer.zig");
const debug = @import("../log.zig").debug;

pub fn render(reg: *ecs.Registry) void {
    rl.beginBlendMode(rl.BlendMode.alpha);
    defer rl.endBlendMode();
    var view = reg.view(.{ comp.RenderTag, comp.RectangleTag, comp.Position, comp.Size, comp.Colour }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const pos = view.getConst(comp.Position, e);
        const size = view.getConst(comp.Size, e);
        const color = view.getConst(comp.Colour, e);
        const rl_colour = color.toRaylib();

        rl.drawRectangle(toInt(pos.x), toInt(pos.y), toInt(size.width), toInt(size.height), rl_colour);
    }

    animateRender(reg);

    if (comp.OverlayTag.active) {
        animateFullRender(reg);
    }
}

fn groundedRender(reg: *ecs.Registry) void {
    var view = reg.view(.{ comp.PlayerTag, comp.Grounded }, .{});
    var iter = view.entityIterator();

    while (iter.next()) |e| {
        const grounded = view.getConst(comp.Grounded, e);
        const text = if (grounded.value) "Grounded" else "Airborne";
        rl.drawText(text, 10, 10, 40, .white);
    }
}

fn animateFullRender(reg: *ecs.Registry) void {
    var view = reg.view(.{ comp.RenderTag, comp.Animate, comp.PlayerTag, comp.Size, comp.Position }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate = view.get(comp.Animate, e);
        const pos = view.get(comp.Position, e);
        const size = view.get(comp.Size, e);
        const sprite = animate.get_sprite();

        rl.drawTexture(sprite.texture.?, 0, 0, .white);

        for (0..sprite.num_frames) |frame| {
            rl.drawRectangleLines(
                toInt(toFloat(frame) * (toFloat(sprite.texture.?.width) / toFloat(sprite.num_frames)) +
                    (sprite.rectangle.width + toFloat(sprite.padding))),
                toInt(toFloat(sprite.texture.?.height) - 38),
                20,
                38,
                if (sprite.current_frame == toFloat(frame)) .blue else .white,
            );
        }

        rl.drawRectangleLines(
            toInt(pos.x),
            toInt(pos.y),
            toInt(size.width),
            toInt(size.height),
            .red,
        );
    }
}

fn animateRender(reg: *ecs.Registry) void {
    var view = reg.view(.{ comp.Animate, comp.PlayerTag, comp.Size, comp.Position }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate = view.get(comp.Animate, e);
        const pos = view.get(comp.Position, e);
        const size = view.get(comp.Size, e);

        const sprite = animate.get_sprite();

        const dest_rect = rl.Rectangle{
            .x = pos.x,
            .y = pos.y,
            .width = size.width,
            .height = size.height,
        };

        rl.drawTexturePro(
            sprite.texture.?,
            sprite.rectangle,
            dest_rect,
            rl.Vector2{ .x = 0, .y = 0 },
            0,
            rl.Color{ .r = 255, .g = 255, .b = 255, .a = 255 },
        );
    }
}

fn toFloat(x: anytype) f32 {
    return @floatFromInt(x);
}
fn toInt(f: f32) i32 {
    return @intFromFloat(f);
}
