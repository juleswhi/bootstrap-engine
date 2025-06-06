const rl = @import("raylib");
const ecs = @import("ecs");

pub const Camera = struct {
    cam: rl.Camera2D,

    pub fn new(width: f32) Camera {
        return .{
            .cam = rl.Camera2D{
                // .offset = .{ .x = width / 2, .y = height / 2 },
                .offset = .{ .x = width / 2, .y = 0 },
                .target = .{ .x = 0, .y = 0 },
                .rotation = 0,
                .zoom = 1,
            },
        };
    }

    pub fn get(reg: *ecs.Registry) ?*Camera {
        const view = reg.view(.{Camera}, .{});
        var iter = view.entityIterator();

        const c: ecs.Entity = iter.next() orelse return null;

        const rl_cam: *Camera = view.get(c);
        return rl_cam;
    }
};
