const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const comp = @import("../components/components.zig");
const Level = @import("../level.zig").Level;
const serialiser = @import("../serializer.zig");
const debug = @import("../log.zig").debug;

pub fn render(reg: *ecs.Registry) void {
    var view = reg.view(.{ comp.RenderTag, comp.Position, comp.Size, comp.Colour }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const pos = view.getConst(comp.Position, e);
        const size = view.getConst(comp.Size, e);
        const color = view.getConst(comp.Colour, e);
        const rl_colour = color.toRaylib();

        rl.drawRectangle(toInt(pos.x), toInt(pos.y), toInt(size.width), toInt(size.height), rl_colour);
    }

    animateRender(reg);
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

fn animateRender(reg: *ecs.Registry) void {
    var view = reg.view(.{ comp.Animate, comp.PlayerTag }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const animate = view.get(comp.Animate, e);
        const pos = view.get(comp.Position, e);

        const texture = switch (animate.state) {
            .idle => animate.idle_texture,
            .run => animate.run_texture,
        };

        const rect: rl.Rectangle = switch (animate.state) {
            .idle => animate.idle_rec,
            .run => animate.run_rec,
        };

        const new_pos = comp.Position.new(pos.x - 35, pos.y - 40);

        rl.drawTextureRec(texture.?, rect, new_pos.toVector(), .white);
    }
}

fn toInt(f: f32) i32 {
    return @intFromFloat(f);
}
