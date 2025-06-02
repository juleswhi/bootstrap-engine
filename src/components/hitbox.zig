const rl = @import("raylib");

pub const Hitbox = struct {
    x: f32 = 0,
    y: f32 = 0,
    width: f32 = 0,
    height: f32 = 0,

    pub fn new(x: f32, y: f32, width: f32, height: f32) @This() {
        return Hitbox{ .x = x, .y = y, .width = width, .height = height };
    }

    pub fn toVector(self: @This()) rl.Vector2 {
        return rl.Vector2{ .x = self.x, .y = self.y };
    }

    pub fn toRect(self: @This()) rl.Rectangle {
        return rl.Rectangle{ .x = self.x, .y = self.y, .width = self.width, .height = self.height };
    }

    pub fn toIntRect(self: @This()) struct { x: i32, y: i32, width: i32, height: i32 } {
        return .{ .x = toInt(self.x), .y = toInt(self.y), .width = toInt(self.width), .height = toInt(self.height) };
    }
};

fn toInt(x: f32) i32 {
    return @intFromFloat(x);
}
