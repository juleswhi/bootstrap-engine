const std = @import("std");
const rl = @import("raylib");
const Sprite = @import("sprite.zig").Sprite;

pub const AnimateType = enum {
    idle,
    run,
    jump,
    punch,
};

pub const Animate = struct {
    sprites: []Sprite,
    type: AnimateType = .idle,
    previous_type: AnimateType = .idle,
    direction: i8 = 1,

    pub fn get_sprite(self: *Animate) *Sprite {
        const name: [:0]const u8 = switch (self.type) {
            .idle => "idle",
            .run => "run",
            .jump => "jump",
            .punch => "punch",
        };

        for (self.sprites) |*s| {
            if (std.mem.eql(u8, name, s.name)) {
                return s;
            }
        }

        return &self.sprites[0];
    }

    pub fn type_to_str(t: AnimateType) []const u8 {
        return switch(t) {
            .idle => "idle",
            .run => "run",
            .jump => "jump",
            .punch => "punch",
        };
    }

    pub fn set_animation(self: *Animate, t: AnimateType) void {
        self.previous_type = self.type;
        self.type = t;
        for(self.sprites) |*s| {
            if(!std.mem.eql(u8, type_to_str(self.type), s.name)) {
                s.current_frame = 0;
            }
        }
    }
};
