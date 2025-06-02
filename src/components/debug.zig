const rl = @import("raylib");
pub const Debug = struct {
    pub var active: bool = true;

    pub fn toggle() void {
        Debug.active = !Debug.active;
    }
};
