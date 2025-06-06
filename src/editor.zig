const std = @import("std");
const Level = @import("level.zig").Level;
const comp = @import("components/components.zig");
const LevelRectangle = @import("level.zig").LevelRectangle;
const sd = @import("log.zig");
const rl = @import("raylib");
const ecs = @import("ecs");

pub const LevelEditor = struct {
    pub var active: bool = false;

    pub fn add_rectangle(reg: *ecs.Registry, point: rl.Vector2) !void {
        var count: i32 = 0;

        var rect_view = reg.view(.{comp.Hitbox}, .{comp.PlayerTag});
        var rect_iter = rect_view.entityIterator();
        while (rect_iter.next()) |e| {
            _ = e;
            count += 1;
        }

        const rect = reg.create();
        reg.add(rect, comp.Environment{ .render = true });
        reg.add(rect, comp.Colour.new(166, 151, 156, 255));
        reg.add(rect, comp.Hitbox{ .x = point.x - 50, .y = point.y - 50, .width = 100, .height = 100 });
    }

    pub fn remove_rectangle(reg: *ecs.Registry, point: rl.Vector2) !void {
        const cam_view = reg.view(.{comp.Camera}, .{});
        var cam_iter = cam_view.entityIterator();
        const next = cam_iter.next() orelse return;
        const camera = cam_view.get(next);

        sd.debug("Clicked right click", .{});

        var rect_view = reg.view(.{comp.Hitbox}, .{comp.PlayerTag});
        var rect_iter = rect_view.entityIterator();
        while (rect_iter.next()) |e| {
            const hitbox = rect_view.getConst(comp.Hitbox, e);
            var vec = hitbox.toRect();
            vec.x += hitbox.width;
            sd.debug("Looping through rects", .{});
            const mouse_pos = rl.getScreenToWorld2D(point, camera.cam);
            if (rl.checkCollisionPointRec(mouse_pos, .{
                .x = hitbox.x,
                .y = hitbox.y,
                .width = hitbox.width,
                .height = hitbox.height,
            })) {
                sd.debug("Removing rectangle", .{});
                reg.destroy(e);
            }
        }
    }
};
