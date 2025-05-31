const rl = @import("raylib");

pub const PlayerAnimateState = union(enum) {
    idle: i32,
    run: i32,
};

pub const PlayerAnimate = struct {
    idle_texture: ?rl.Texture2D = null,
    run_texture: ?rl.Texture2D = null,
    idle_rec: rl.Rectangle = rl.Rectangle{ .x = 0, .y = 0, .width = 0, .height = 0 },
    run_rec: rl.Rectangle = rl.Rectangle{ .x = 0, .y = 0, .width = 0, .height = 0 },
    state: PlayerAnimateState = .{ .idle = 0 },
    frame_speed: u32 = 6,
    idle_frames: i32 = 10,
    run_frames: i32 = 16,
    accumulator: f32 = 0.0,
};
