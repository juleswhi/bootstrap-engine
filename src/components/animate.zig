const std = @import("std");
const rl = @import("raylib");
const Sprite = @import("sprite.zig").Sprite;

pub const AnimateType = enum {
    idle,
};

pub const Animate = struct {
    sprites: []Sprite,
    type: AnimateType = .idle,
    frame_speed: u32 = 3,

    pub fn get_sprite(self: *Animate) *Sprite {
        const name: [:0]const u8 = switch (self.type) {
            .idle => "idle",
        };

        for (self.sprites) |*s| {
            if (std.mem.eql(u8, name, s.name)) {
                return s;
            }
        }

        return &self.sprites[0];
    }
};
