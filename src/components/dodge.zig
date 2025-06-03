const rl = @import("raylib");
pub const Dodge = struct {
    is_dodging: bool = false,
    direction: f32 = 0,
    remaining_time: f32 = 0,
    duration: f32 = 0.4,
    speed: f32 = 1000,
    cooldown: f32 = 0.5,
    cooldown_timer: f32 = 0,
};
