const Level = @import("level.zig").Level;
const LevelRectangle = @import("level.zig").LevelRectangle;
const Hitbox = @import("components/hitbox.zig").Hitbox;
const serialiser = @import("serializer.zig");
const std = @import("std");
const sd = @import("log.zig");

pub fn serialise_level_one() !void {
    sd.debug("Running serialize level one ", .{});

    var rects = [_]LevelRectangle{
        .{ .hitbox = Hitbox{ .x = -500_000, .y = 790, .width = 1_000_000, .height = 100 }, .render = true },
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
    try serialiser.writeJsonFile("src/levels/level_one.json", json_str);

    const decoded_level = try serialiser.deserialiseLevel(json_str);
    defer std.heap.page_allocator.free(decoded_level.rects);
}

pub fn serialise_test_two() !void {
    var rects = [_]LevelRectangle{
        .{ .hitbox = Hitbox{ .x = -500_000, .y = 790, .width = 1_000_000, .height = 100 }, .render = true },
        .{ .hitbox = Hitbox{ .x = 900, .y = 700, .width = 375, .height = 900 }, .render = true },
        .{ .hitbox = Hitbox{ .x = 0, .y = 684, .width = 563, .height = 900 }, .render = true },
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
    try serialiser.writeJsonFile("src/levels/level_two.json", json_str);

    const decoded_level = try serialiser.deserialiseLevel(json_str);
    defer std.heap.page_allocator.free(decoded_level.rects);

}

test "Serialise Level One" {
    sd.debug("Running serialize level one ", .{});
    const screen_width = 1500;
    const screen_height = 820;

    var rects = [_]LevelRectangle{
        .{ .hitbox = Hitbox{ .x = 0, .y = screen_height + 20, .width = 1_000_000, .height = 20 }, .render = true },
        .{ .hitbox = Hitbox{ .x = -10, .y = 0, .width = 40, .height = screen_height }, .render = false },
        .{ .hitbox = Hitbox{ .x = screen_width - 20, .y = 0, .width = 40, .height = screen_height }, .render = false },
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
    try serialiser.writeJsonFile("src/levels/level_one.json", json_str);

    const decoded_level = try serialiser.deserialiseLevel(json_str);
    defer std.heap.page_allocator.free(decoded_level.rects);
}

test "Serialise Level Two" {
    var rects = [_]LevelRectangle{
        .{ .hitbox = Hitbox{ .x = 0, .y = 810, .width = 1_000_000, .height = 53 }, .render = true },
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
    try serialiser.writeJsonFile("src/levels/level_two.json", json_str);

    const decoded_level = try serialiser.deserialiseLevel(json_str);
    defer std.heap.page_allocator.free(decoded_level.rects);
}
