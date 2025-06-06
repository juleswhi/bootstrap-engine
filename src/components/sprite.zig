const rl = @import("raylib");
const AnimateType = @import("../components/animate.zig").AnimateType;

// increase jump height

pub const Sprite = struct {
    name: []const u8,
    image_data: []const u8,
    texture: ?rl.Texture2D = null,
    rectangle: rl.Rectangle = rl.Rectangle{ .x = 0, .y = 0, .width = 0, .height = 0 },
    current_frame: f32 = 0,
    accumulator: f32 = 0,
    num_frames: u32,
    frame_speed: u32 = 3,
    width: u32 = 0,
    height: u32 = 0,
    looping: bool = true,
    offset_x: f32 = 0,
    offset_y: f32 = 0,
    next: ?AnimateType = null,

    pub fn new(name: []const u8, image_data: []const u8, num_frames: u32, width: u32, height: u32, frame_speed: u32, looping: bool, offset_x: f32, offset_y: f32) Sprite {
        return Sprite{
            .name = name,
            .image_data = image_data,
            .num_frames = num_frames,
            .width = width,
            .height = height,
            .frame_speed = frame_speed,
            .looping = looping,
            .offset_x = offset_x,
            .offset_y = offset_y,
        };
    }

    pub fn add_next(self: *const Sprite, next: AnimateType) Sprite {
        var s = self.*;
        s.next = next;
        return s;
    }
};
