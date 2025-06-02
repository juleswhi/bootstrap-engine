const rl = @import("raylib");

pub const Sprite = struct {
    name: []const u8,
    texture_path: [:0]const u8,
    texture: ?rl.Texture2D = null,
    rectangle: rl.Rectangle = rl.Rectangle{
        .x = 0,
        .y = 0,
        .width = 0,
        .height = 0,
    },
    current_frame: f32 = 0,
    num_frames: u32,
    width: u32 = 0,
    height: u32 = 0,
    padding: u32 = 0,

    pub fn new(name: []const u8, path: [:0]const u8, num_frames: u32, width: u32, height: u32, padding: u32) Sprite {
        return Sprite{
            .name = name,
            .texture_path = path,
            .num_frames = num_frames,
            .width = width,
            .height = height,
            .padding = padding,
        };
    }
};
