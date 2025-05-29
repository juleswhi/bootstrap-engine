const rl = @import("raylib");

pub const Velocity = struct {
    x: f32,
    y: f32,

    pub fn new(x: f32, y: f32) Velocity {
        return Velocity{ .x = x, .y = y };
    }

    pub fn toVector(self: Velocity) rl.Vector2 {
        return rl.Vector2{ .x = self.x, .y = self.y };
    }
};
