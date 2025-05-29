const rl = @import("raylib");

pub const Position = struct {
    x: f32,
    y: f32,

    pub fn new(x: f32, y: f32) Position {
        return Position{ .x = x, .y = y };
    }

    pub fn toVector(self: Position) rl.Vector2 {
        return rl.Vector2{ .x = self.x, .y = self.y };
    }
};
