const rl = @import("raylib");

pub const AABB = struct {
    min: rl.Vector2,
    max: rl.Vector2,
    vel: rl.Vector2,
    mass: f32,
    restitution: f32,

    pub fn vs(a: AABB, b: AABB) bool {
        if(a.max.x < b.min.y or a.min.x > b.max.y) return false;
        if(a.max.y < b.min.y or a.min.y > b.max.y) return false;

        return true;
    }

    pub fn invMass(a: *AABB) f32 {
        if(a.mass == 0) return 0;
        return 1 / a.mass;
    }
};
