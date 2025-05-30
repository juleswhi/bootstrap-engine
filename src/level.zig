const std = @import("std");
const ecs = @import("ecs");
const comp = @import("components/components.zig");
const log = @import("log.zig");
const json = std.json;

pub const Rect = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    render: bool = true,
};

pub const Level = struct {
    rects: []Rect,

    pub fn free(level: *Level) void {
        std.heap.page_allocator.free(level.rects);
        log.debug("Freeing Level Memory", .{});
    }

    // Will prolly need to refactor if supporting multiple screen resolutions
    pub fn to_ecs(level: *const Level, reg: *ecs.Registry) void {
        for (level.rects) |rect| {
            log.debug("Rect render is: {}", .{rect.render});
            const e = reg.create();
            reg.add(e, comp.Position.new(rect.x, rect.y));
            reg.add(e, comp.Size.new(rect.width, rect.height));
            reg.add(e, comp.Colour.new(0, 255, 0, 255));
            reg.add(e, comp.EnvironmentTag{});
            if (rect.render) {
                reg.add(e, comp.RenderTag{});
            }
        }
    }
};
