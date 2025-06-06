const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const sd = @import("../log.zig");
const builtin = @import("builtin");
const main = @import("../main.zig");
// const windows = builtin.os.tag == .windows;
const windows = false;

// TODO: Fix punch animation
pub fn cameraRender(reg: *ecs.Registry) void {
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
}

pub fn screenRender(reg: *ecs.Registry) void {
    if (comp.Debug.active) {
        debugRender(reg);
    } else {
        controlRender();
    }
}

const DragState = struct {
    entity: ecs.Entity,
    start_mouse: rl.Vector2,
    start_hitbox: comp.Hitbox,
};

var drag_state: ?DragState = null;

var previous_mouse_pos: rl.Vector2 = rl.Vector2.zero();

fn debugRender(reg: *ecs.Registry) void {
    var view = reg.view(.{ comp.Animate, comp.Hitbox, comp.Canvas, comp.PlayerTag }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate = view.get(comp.Animate, e);
        const velocity = view.get(comp.Velocity, e);
        const sprite = animate.get_sprite();

        rl.drawText("Debug Mode", 10, 150, 20, .black);

        const vel_x = toSentinel(.{toInt(velocity.x)});
        defer std.heap.page_allocator.free(vel_x);
        const vel_y = toSentinel(.{toInt(velocity.y)});
        defer std.heap.page_allocator.free(vel_y);
        const sprite_name = toSentinelString(.{comp.Animate.type_to_str(animate.type)});
        defer std.heap.page_allocator.free(sprite_name);
        const dt_modifier = std.fmt.allocPrintZ(std.heap.page_allocator, "DeltaTime: {d}", .{main.DELTA_TIME_MODIFIER}) catch unreachable;
        defer std.heap.page_allocator.free(dt_modifier);

        rl.drawText(vel_x, 10, 170, 20, .black);
        rl.drawText(vel_y, 10, 190, 20, .black);
        rl.drawText(sprite_name, 10, 210, 20, .black);
        rl.drawText(dt_modifier, 10, 230, 20, .black);
        rl.drawTexture(sprite.texture.?, 0, 0, .white);

        for (0..sprite.num_frames) |frame| {
            const x = toInt(toFloat(frame) * (toFloat(sprite.texture.?.width) / toFloat(sprite.num_frames)));
            rl.drawRectangleLines(
                x,
                0,
                toInt(toFloat(sprite.texture.?.width) / toFloat(sprite.num_frames)),
                sprite.texture.?.height,
                if (sprite.current_frame == toFloat(frame)) .red else .black,
            );
            const str = std.fmt.allocPrintZ(std.heap.page_allocator, "{}", .{frame}) catch unreachable;
            defer std.heap.page_allocator.free(str);
            rl.drawText(str, x + 10, 100, 20, .black);
        }
    }

    const cam_entity = reg.basicView(comp.Camera).data()[0];
    const cam = reg.get(comp.Camera, cam_entity);

    rl.drawRectangleLines(
        toInt(cam.follow_rec.x),
        toInt(cam.follow_rec.y),
        toInt(cam.follow_rec.width),
        toInt(cam.follow_rec.height),
        .purple,
    );

    var rect_view = reg.view(.{ comp.Hitbox, comp.Environment }, .{comp.PlayerTag});
    var rect_iter = rect_view.entityIterator();
    while (rect_iter.next()) |e| {
        var hitbox: *comp.Hitbox = reg.get(comp.Hitbox, e);
        const r = hitbox.toRect();
        const r_screen = rl.getWorldToScreen2D(.{ .x = r.x, .y = r.y }, cam.cam);
        const mouse_pos = rl.getMousePosition();

        if (rl.checkCollisionPointRec(mouse_pos, .{ .x = r_screen.x, .y = r_screen.y, .width = r.width, .height = r.height })) {
            const hb_screen = rl.getWorldToScreen2D(.{ .x = hitbox.x, .y = hitbox.y }, cam.cam);
            rl.drawRectangleLines(toInt(hb_screen.x), toInt(hb_screen.y), toInt(hitbox.width), toInt(hitbox.height), .gray);

            if (rl.isMouseButtonPressed(.middle)) {
                reg.destroy(e);
            }

            if(rl.isMouseButtonDown(.left)) {
                const m = rl.getScreenToWorld2D(mouse_pos, cam.cam);
                hitbox.x = m.x - (0.5 * hitbox.width);
                hitbox.y = m.y - (0.5 * hitbox.height);
            }

            if (rl.isMouseButtonPressed(.right)) {
                drag_state = .{
                    .entity = e,
                    .start_mouse = rl.getScreenToWorld2D(mouse_pos, cam.cam),
                    .start_hitbox = hitbox.*, // Copy current hitbox
                };
            }
        }
    }

    if (rl.isMouseButtonDown(.right) and drag_state != null) {
        var hitbox = reg.get(comp.Hitbox, drag_state.?.entity);
        const current_mouse = rl.getScreenToWorld2D(rl.getMousePosition(), cam.cam);
        const delta = rl.Vector2.subtract(current_mouse, drag_state.?.start_mouse);

        hitbox.width = drag_state.?.start_hitbox.width + delta.x;
        hitbox.height = drag_state.?.start_hitbox.height + delta.y;

        hitbox.width = @max(hitbox.width, 10);
        hitbox.height = @max(hitbox.height, 10);
    }

    if (rl.isMouseButtonReleased(.right)) {
        drag_state = null;
    }
}

fn controlRender() void {}

fn toSentinel(args: anytype) [:0]u8 {
    const str = std.fmt.allocPrintZ(std.heap.page_allocator, "{}", args) catch unreachable;
    return str;
}

fn toSentinelString(args: anytype) [:0]u8 {
    const str = std.fmt.allocPrintZ(std.heap.page_allocator, "{s}", args) catch unreachable;
    return str;
}

fn animateRender(reg: *ecs.Registry) void {
    var view = reg.view(.{ comp.Animate, comp.Canvas, comp.Hitbox }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate = view.get(comp.Animate, e);
        var canvas = view.get(comp.Canvas, e);
        const hitbox = view.get(comp.Hitbox, e);

        var sprite = animate.get_sprite();

        canvas.width = toFloat(sprite.width) * canvas.scale_x;
        canvas.height = toFloat(sprite.height) * canvas.scale_y;
        // sd.debug("{s} sprite has width of {d}, new canvas width is: {d}", .{sprite.name, sprite.width, canvas.width});
        // sd.debug("{s} sprite has height of {d}, new canvas width is: {d}", .{sprite.name, sprite.height, canvas.height});

        if (rl.isKeyPressed(.comma)) {
            sprite.offset_y -= 1;
            sd.debug("new y offset is: {d}", .{sprite.offset_y});
        } else if (rl.isKeyPressed(.period)) {
            sprite.offset_y += 1;
            sd.debug("new y offset is: {d}", .{sprite.offset_y});
        }

        sprite.rectangle.x =
            (sprite.current_frame * (toFloat(sprite.texture.?.width) / toFloat(sprite.num_frames)));

        const hitbox_center_x = hitbox.x + (0.5 * hitbox.width);
        const hitbox_center_y = hitbox.y + (0.5 * hitbox.height);

        // const canvas_center_x = hitbox_center_x - ()

        const x = hitbox_center_x - (0.5 * canvas.width);
        // const y = hitbox_center_y - sprite.offset_y;
        const y = hitbox_center_y - (0.5 * canvas.height);

        const dest_rect = rl.Rectangle{
            .x = x,
            .y = y - sprite.offset_y,
            .width = canvas.width,
            .height = canvas.height,
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

        if (comp.Debug.active) {
            rl.drawRectangleLines(
                toInt(x),
                toInt(y),
                toInt(canvas.width),
                toInt(canvas.height),
                .blue,
            );
            rl.drawRectangleLines(
                toInt(hitbox.x),
                toInt(hitbox.y),
                toInt(hitbox.width),
                toInt(hitbox.height),
                .red,
            );
        }
    }
}

fn toFloat(x: anytype) f32 {
    return @floatFromInt(x);
}

fn toInt(f: f32) i32 {
    return @intFromFloat(f);
}
