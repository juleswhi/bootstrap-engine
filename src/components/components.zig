const Level = @import("../level.zig").Level;

pub const Position = @import("position.zig").Position;
pub const Velocity = @import("velocity.zig").Velocity;
pub const Size = @import("size.zig").Size;
pub const Colour = @import("colour.zig").Colour;
pub const Grounded = @import("grounded.zig").Grounded;
pub const Jump = @import("jump.zig").Jump;
pub const Dodge = @import("dodge.zig").Dodge;

pub const LevelTag = struct { level: *Level };
pub const PlayerTag = struct {};
pub const EnvironmentTag = struct {};
pub const GravityTag = struct {};
pub const RenderTag = struct {};
