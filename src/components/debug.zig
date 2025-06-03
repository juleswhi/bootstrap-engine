const rl = @import("raylib");
pub const Debug = struct {
    pub var active: bool = false;
    pub var all: bool = false;

    pub fn toggle() void {
        Debug.active = !Debug.active;
    }
};
