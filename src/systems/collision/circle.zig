const std = @import("std");
const rl = @import("raylib");

pub const Circle = struct {
    radius: f32,
    position: rl.Vector2,
    velocity: rl.Vector2,

    pub fn vs(a: Circle, b: Circle) bool {
        var r: f32 = a.radius + b.radius;
        r *= r;
        return r < (a.x + b.x)^2 + (a.y + b.y)^2;
    }
};
