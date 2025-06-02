const Level = @import("../level.zig").Level;

pub const Position = @import("position.zig").Position;
pub const Velocity = @import("velocity.zig").Velocity;
pub const Size = @import("size.zig").Size;
pub const Colour = @import("colour.zig").Colour;
pub const Grounded = @import("grounded.zig").Grounded;
pub const Jump = @import("jump.zig").Jump;
pub const Dodge = @import("dodge.zig").Dodge;
pub const Sprite = @import("sprite.zig").Sprite;
pub const Animate = @import("animate.zig").Animate;
pub const Hitbox = @import("hitbox.zig").Hitbox;
pub const Canvas = @import("canvas.zig").Canvas;
pub const LevelTag = struct { level: *Level };
pub const Environment = struct { render: bool = false };

pub const Debug = @import("debug.zig").Debug;
pub const PlayerTag = struct {};
pub const Gravity = struct {};
