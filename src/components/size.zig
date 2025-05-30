const rl = @import("raylib");

pub const Size = struct {
    width: f32,
    height: f32,

    pub fn new(width: f32, height: f32) Size {
        return Size{ .width = width, .height = height };
    }
    pub fn toVector(self: Size) rl.Vector2 {
        return rl.Vector2{ .x = self.width, .y = self.height };
    }
};
