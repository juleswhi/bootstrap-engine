const rl = @import("raylib");

pub const Scale = struct {
    x: f32,
    y: f32,

    pub fn new(x: f32, y: f32) Scale {
        return Scale{ .x = x, .y = y };
    }
    pub fn toVector(self: Scale) rl.Vector2 {
        return rl.Vector2{ .x = self.x, .y = self.y };
    }
};
