const std = @import("std");
const rl = @import("raylib");
const AABB = @import("aabb.zig").AABB;

pub fn resolveCollision(a: *AABB, b: *AABB) void {
    const centerA = rl.Vector2{ .x = (a.min.x + a.max.x) * 0.5, .y = (a.min.y + a.max.y) * 0.5 };
    const centerB = rl.Vector2{ .x = (b.min.x + b.max.x) * 0.5, .y = (b.min.y + b.max.y) * 0.5 };

    const overlapX = @min(a.max.x, b.max.x) - @max(a.min.x, b.min.x);
    const overlapY = @min(a.max.y, b.max.y) - @max(a.min.y, b.min.y);

    var normal: rl.Vector2 = undefined;
    if (overlapX < overlapY) {
        normal = if (centerA.x < centerB.x)
            rl.Vector2{ .x = 1, .y = 0 }
        else
            rl.Vector2{ .x = -1, .y = 0 };
    } else {
        normal = if (centerA.y < centerB.y)
            rl.Vector2{ .x = 0, .y = 1 }
        else
            rl.Vector2{ .x = 0, .y = -1 };
    }

    const rv = b.vel.subtract(a.vel);
    const velAlongNormal = rv.dotProduct(normal);

    if (velAlongNormal > 0) return;

    const e = @min(a.restitution, b.restitution);

    var j = -(1 + e) * velAlongNormal;
    const invA = if (a.mass == 0) 0 else 1 / a.mass;
    const invB = if (b.mass == 0) 0 else 1 / b.mass;
    j /= invA + invB;

    const impulse = normal.scale(j);
    a.vel = a.vel.subtract(impulse.scale(invA));
    b.vel = b.vel.add(impulse.scale(invB));
}

const percent: f32 = 0.2;
const slop: f32 = 0.01;

pub fn positionalCorrection(a: *AABB, b: *AABB) void {
    // Calculate centers
    const centerA = rl.Vector2{ .x = (a.min.x + a.max.x) * 0.5, .y = (a.min.y + a.max.y) * 0.5 };
    const centerB = rl.Vector2{ .x = (b.min.x + b.max.x) * 0.5, .y = (b.min.y + b.max.y) * 0.5 };

    // Calculate overlap on each axis
    const overlapX = @min(a.max.x, b.max.x) - @max(a.min.x, b.min.x);
    const overlapY = @min(a.max.y, b.max.y) - @max(a.min.y, b.min.y);

    // Determine collision normal and penetration depth
    var normal: rl.Vector2 = undefined;
    var penetration: f32 = undefined;
    if (overlapX < overlapY) {
        normal = if (centerA.x < centerB.x)
            rl.Vector2{ .x = 1, .y = 0 }
        else
            rl.Vector2{ .x = -1, .y = 0 };
        penetration = overlapX;
    } else {
        normal = if (centerA.y < centerB.y)
            rl.Vector2{ .x = 0, .y = 1 }
        else
            rl.Vector2{ .x = 0, .y = -1 };
        penetration = overlapY;
    }

    // Calculate inverse masses (handle infinite mass)
    const invA = if (a.mass == 0) 0 else 1 / a.mass;
    const invB = if (b.mass == 0) 0 else 1 / b.mass;

    // Calculate correction magnitude
    const correction_magnitude = @max(penetration - slop, 0.0) / (invA + invB) * percent;
    const correction = rl.Vector2Scale(normal, correction_magnitude);

    // Calculate position shifts
    const shiftA = rl.Vector2Scale(correction, -invA);
    const shiftB = rl.Vector2Scale(correction, invB);

    // Apply correction to AABB positions
    a.min = rl.Vector2Add(a.min, shiftA);
    a.max = rl.Vector2Add(a.max, shiftA);
    b.min = rl.Vector2Add(b.min, shiftB);
    b.max = rl.Vector2Add(b.max, shiftB);
}
