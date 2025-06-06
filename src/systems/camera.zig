const Camera = @import("../components/camera.zig").Camera;
const comp = @import("../components/components.zig");
const rl = @import("raylib");
const ecs = @import("ecs");
const sd = @import("../log.zig");

pub fn camera(reg: *ecs.Registry, cam: *Camera) void {
    var view = reg.view(.{ comp.PlayerTag, comp.Hitbox }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |e| {
        const player_tag = view.get(comp.PlayerTag, e);
        if (player_tag.id != cam.follow_id) continue;
        const hitbox = view.get(comp.Hitbox, e);

        const cam_world_x = rl.getScreenToWorld2D(.{ .x = cam.follow_rec.x, .y = 0 }, cam.cam).x;
        if (hitbox.x < cam_world_x) {
            cam.follow_rec.x = rl.getWorldToScreen2D(.{ .x = hitbox.x, .y = 0 }, cam.cam).x;
        }
        if ((hitbox.x + hitbox.width) > (cam_world_x + cam.follow_rec.width)) {
            cam.follow_rec.x = rl.getWorldToScreen2D(.{ .x = hitbox.x + hitbox.width - cam.follow_rec.width, .y = 0 }, cam.cam).x;
        }
    }
}
