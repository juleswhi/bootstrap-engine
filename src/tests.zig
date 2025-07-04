const Level = @import("level.zig").Level;
const LevelRectangle = @import("level.zig").LevelRectangle;
const Hitbox = @import("components/hitbox.zig").Hitbox;
const serialiser = @import("serializer.zig");
const std = @import("std");
const sd = @import("stardust");

test "Serialise Level One" {
    const screen_width = 1500;
    const screen_height = 800;

    var rects = [_]LevelRectangle{
        .{ .hitbox = Hitbox{ .x = 0, .y = screen_height + 10, .width = screen_width, .height = 30 }, .render = true },
        .{ .hitbox = Hitbox{ .x = -10, .y = 0, .width = 40, .height = screen_height }, .render = false },
        .{ .hitbox = Hitbox{ .x = screen_width - 30, .y = 0, .width = 40, .height = screen_height }, .render = false },
    };

    var level = Level{
        .name = &"Level One".*,
        .start_x = 400,
        .start_y = 250,
        .rects = &rects,
    };

    const json_str = try serialiser.serialiseLevel(&level);
    defer std.heap.page_allocator.free(json_str);
    sd.debug("{s}\n", .{json_str});
    try serialiser.writeJsonFile("levels/level_one.json", json_str);

    const decoded_level = try serialiser.deserialiseLevel(json_str);
    defer std.heap.page_allocator.free(decoded_level.rects);

    try std.testing.expectEqual(level.rects.len, decoded_level.rects.len);
    try std.testing.expectEqual(level.rects[0], decoded_level.rects[0]);
}

test "Serialise Level Two" {
    var rects = [_]LevelRectangle{
        .{ .hitbox = Hitbox{ .x = 0, .y = 810, .width = 1500, .height = 53 }, .render = true },
        .{ .hitbox = Hitbox{ .x = -19, .y = 0, .width = 75, .height = 889 }, .render = true },
        .{ .hitbox = Hitbox{ .x = 1444, .y = 0, .width = 75, .height = 889 }, .render = true },
        .{ .hitbox = Hitbox{ .x = 938, .y = 747, .width = 375, .height = 889 }, .render = true },
        .{ .hitbox = Hitbox{ .x = 0, .y = 684, .width = 563, .height = 889 }, .render = true },
    };

    var level = Level{
        .name = &"Level Two".*,
        .start_x = 400,
        .start_y = 250,
        .rects = &rects,
    };

    const json_str = try serialiser.serialiseLevel(&level);
    defer std.heap.page_allocator.free(json_str);
    sd.debug("{s}\n", .{json_str});
    try serialiser.writeJsonFile("levels/level_two.json", json_str);

    const decoded_level = try serialiser.deserialiseLevel(json_str);
    defer std.heap.page_allocator.free(decoded_level.rects);

    try std.testing.expectEqual(level.rects.len, decoded_level.rects.len);
    try std.testing.expectEqual(level.rects[0], decoded_level.rects[0]);
}
