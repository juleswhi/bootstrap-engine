const rl = @import("raylib");

pub const Size = struct {
    width: f32,
    height: f32,

    pub fn new(x: f32, y: f32) Size {
        return Size{ .width = x, .height = y };
    }
    pub fn toVector(self: Size) rl.Vector2 {
        return rl.Vector2{ .x = self.width, .y = self.height };
    }
};
