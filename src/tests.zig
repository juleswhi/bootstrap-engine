const Rect = @import("level.zig").Rect;
const Level = @import("level.zig").Level;
const serialiser = @import("serializer.zig");
const std = @import("std");
const debug = @import("log.zig").debug;


test "serialise level one" {
    var rects = [_]Rect{
        .{ .x = 0, .y = 460, .width = 800, .height = 30 },
        .{ .x = -10, .y = 0, .width = 40, .height = 500, .render = false },
        .{ .x = 760, .y = 0, .width = 40, .height = 500, .render = false },
    };

    var level = Level{
        .name = &"Level One".*,
        .start_x = 400,
        .start_y = 250,
        .rects = &rects,
    };

    const json_str = try serialiser.serialiseLevel(&level);
    defer std.heap.page_allocator.free(json_str);
    debug("{s}\n", .{json_str});
    try serialiser.writeJsonFile("levels/level_one.json", json_str);

    const decoded_level = try serialiser.deserialiseLevel(json_str);
    defer std.heap.page_allocator.free(decoded_level.rects);

    try std.testing.expectEqual(level.rects.len, decoded_level.rects.len);
    try std.testing.expectEqual(level.rects[0], decoded_level.rects[0]);
}

test "serialise level two" {
    var rects = [_]Rect{
        .{ .x = 0, .y = 460, .width = 800, .height = 30 },
        .{ .x = -10, .y = 0, .width = 40, .height = 500, .render = false },
        .{ .x = 770, .y = 0, .width = 40, .height = 500, .render = false },
        .{ .x = 500, .y = 420, .width = 200, .height = 500 },
        .{ .x = 0, .y = 385, .width = 300, .height = 500 },
    };

    var level = Level{
        .name = &"Level Two".*,
        .start_x = 400,
        .start_y = 250,
        .rects = &rects,
    };

    const json_str = try serialiser.serialiseLevel(&level);
    defer std.heap.page_allocator.free(json_str);
    debug("{s}\n", .{json_str});
    try serialiser.writeJsonFile("levels/level_two.json", json_str);

    const decoded_level = try serialiser.deserialiseLevel(json_str);
    defer std.heap.page_allocator.free(decoded_level.rects);

    try std.testing.expectEqual(level.rects.len, decoded_level.rects.len);
    try std.testing.expectEqual(level.rects[0], decoded_level.rects[0]);
}
