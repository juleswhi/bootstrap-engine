const rl = @import("raylib");

pub const GravityTag = struct {
    x: f32,
    y: f32,

    pub fn new(x: f32, y: f32) GravityTag {
        return GravityTag{ .x = x, .y = y };
    }

    pub fn toVector(self: GravityTag) rl.Vector2 {
        return rl.Vector2{ .x = self.x, .y = self.y };
    }
};
