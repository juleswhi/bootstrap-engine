const rl = @import("raylib");

pub const AABB = struct {
    min: rl.Vector2,
    max: rl.Vector2,

    pub fn vs(a: AABB, b: AABB) bool {
        if(a.max.x < b.min.y or a.min.x > b.max.y) return false;
        if(a.max.y < b.min.y or a.min.y > b.max.y) return false;

        return true;
    }
};
