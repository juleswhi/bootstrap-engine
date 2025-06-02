const rl = @import("raylib");

pub const Velocity = struct {
    x: f32 = 0,
    y: f32 = 0,

    pub fn new(x: f32, y: f32) Velocity {
        return Velocity{ .x = x, .y = y };
    }

    pub fn toVector(self: Velocity) rl.Vector2 {
        return rl.Vector2{ .x = self.x, .y = self.y };
    }

    pub fn toInt(self: @This()) struct { x: i32, y: i32 } {
        return .{ .x = toInteger(self.x), .y = toInteger(self.y) };
    }
};

fn toInteger(x: f32) i32 {
    return @intFromFloat(x);
}
