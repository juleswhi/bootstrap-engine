const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const sd = @import("../log.zig");
const builtin = @import("builtin");
const windows = builtin.os.tag == .windows;

pub fn render(reg: *ecs.Registry) void {
    rl.beginBlendMode(rl.BlendMode.alpha);
    defer rl.endBlendMode();
    var view = reg.view(.{ comp.Hitbox, comp.Colour, comp.Environment }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const env = view.getConst(comp.Environment, e);
        if (!env.render) continue;
        const color = view.getConst(comp.Colour, e);
        const hitbox = view.getConst(comp.Hitbox, e);
        const rl_colour = color.toRaylib();

        rl.drawRectangle(toInt(hitbox.x), toInt(hitbox.y), toInt(hitbox.width), toInt(hitbox.height), rl_colour);
    }

    animateRender(reg);

    if (comp.Debug.active) {
        debugRender(reg);
    } else {
        controlRender();
    }
}

fn debugRender(reg: *ecs.Registry) void {
    var view = reg.view(.{ comp.Animate, comp.Hitbox, comp.Canvas }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate = view.get(comp.Animate, e);
        const hitbox = view.get(comp.Hitbox, e);
        const velocity = view.get(comp.Velocity, e);
        const canvas = view.get(comp.Canvas, e);
        const sprite = animate.get_sprite();

        rl.drawText("Debug Mode", 10, 150, 20, .white);

        const vel_x = toSentinel(.{toInt(velocity.x)});
        defer std.heap.page_allocator.free(vel_x);
        const vel_y = toSentinel(.{toInt(velocity.y)});
        defer std.heap.page_allocator.free(vel_y);
        rl.drawText(vel_x, 10, 170, 20, .white);
        rl.drawText(vel_y, 10, 190, 20, .white);

        rl.drawTexture(sprite.texture.?, 0, 0, .white);

        for (0..sprite.num_frames) |frame| {
            const x = toInt(toFloat(frame) * (toFloat(sprite.texture.?.width) / toFloat(sprite.num_frames)));
            rl.drawRectangleLines(
                x,
                0,
                toInt(toFloat(sprite.texture.?.width) / toFloat(sprite.num_frames)),
                sprite.texture.?.height,
                if (sprite.current_frame == toFloat(frame)) .blue else .white,
            );
            const str = std.fmt.allocPrintZ(std.heap.page_allocator, "{}", .{frame}) catch unreachable;
            defer std.heap.page_allocator.free(str);
            rl.drawText(str, x + 10, 100, 20, .white);
        }

        rl.drawRectangleLines(
            toInt(hitbox.x),
            toInt(hitbox.y),
            toInt(hitbox.width),
            toInt(hitbox.height),
            .red,
        );

        const hitbox_bottom = hitbox.y + hitbox.height;
        rl.drawRectangleLines(
            toInt((hitbox.x + hitbox.width / 2) - (canvas.width / 2)),
            toInt(hitbox_bottom - canvas.height),
            toInt(canvas.width),
            toInt(canvas.height),
            .blue,
        );
    }
}

fn controlRender() void {
}

fn toSentinel(args: anytype) [:0]u8 {
    const str = std.fmt.allocPrintZ(std.heap.page_allocator, "{}", args) catch unreachable;
    return str;
}

fn animateRender(reg: *ecs.Registry) void {
    var view = reg.view(.{ comp.Animate, comp.Canvas, comp.Hitbox }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate = view.get(comp.Animate, e);
        const canvas = view.get(comp.Canvas, e);
        const hitbox = view.get(comp.Hitbox, e);

        const sprite = animate.get_sprite();

        const hitbox_bottom = hitbox.y + hitbox.height;

        const scale_x = (canvas.width / toFloat(sprite.width));
        const scale_y = (canvas.height / toFloat(sprite.height));

        if (comp.Debug.all) {
            sd.debug("X factor: {}", .{toInt(scale_x)});
            sd.debug("Y factor: {}", .{toInt(scale_y)});
        }

        const dest_rect = rl.Rectangle{
            .x = (hitbox.x + (hitbox.width / 2) - (canvas.width / 2)) + (sprite.offset_x),
            .y = (hitbox_bottom - canvas.height) + (sprite.offset_y),
            .width = canvas.width * (1 / scale_x) * 2,
            .height = canvas.height * (1 / scale_y) * 2,
        };

        var source = sprite.rectangle;
        source.width = toFloat(animate.direction) * source.width;

        rl.drawTexturePro(
            sprite.texture.?,
            source,
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
