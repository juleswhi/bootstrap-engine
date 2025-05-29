const rl = @import("raylib");

pub const Colour = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8 = 255,

    pub fn new(r: u8, g: u8, b: u8, a: u8) Colour {
        return Colour{
            .r = r,
            .g = g,
            .b = b,
            .a = a,
        };
    }

    pub fn toRaylib(self: Colour) rl.Color {
        return rl.Color{ .r = self.r, .g = self.g, .b = self.b, .a = self.a };
    }
};
