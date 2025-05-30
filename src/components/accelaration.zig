const rl = @import("raylib");

pub const Accel = struct {
    x: f32,
    y: f32,

    pub fn new(x: f32, y: f32) Accel {
        return Accel{ .x = x, .y = y };
    }

    pub fn toVector(self: Accel) rl.Vector2 {
        return rl.Vector2{ .x = self.x, .y = self.y };
    }
};
