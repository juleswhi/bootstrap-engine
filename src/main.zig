const std = @import("std");
const rl = @import("raylib");
const comp = @import("components/components.zig");
const ecs = @import("ecs");
const systems = @import("systems.zig");
const Level = @import("level.zig").Level;
const Rect = @import("level.zig").Rect;
const debug = @import("log.zig").debug;
const serialiser = @import("serializer.zig");

pub fn main() !void {
    var reg = ecs.Registry.init(std.heap.page_allocator);

    const width = 800;
    const height = 450;

    createPlayer(&reg, width, height);

    const json = try serialiser.readJsonFile(std.heap.page_allocator, "levels/level_one.json");
    defer std.heap.page_allocator.free(json);

    debug("{s}", .{json});

    const decoded_level = try serialiser.deserialiseLevel(json);
    defer std.heap.page_allocator.free(decoded_level.rects);

    decoded_level.to_ecs(&reg);

    rl.initWindow(width, height, "platformer");
    defer rl.closeWindow();
    rl.setTargetFPS(1000);

    var last_frame_time = rl.getTime();

    while (!rl.windowShouldClose()) {
        const current_time = rl.getTime();
        const dt: f32 = @floatCast(current_time - last_frame_time);
        last_frame_time = current_time;

        systems.inputSystem(&reg, dt);
        systems.gravitySystem(&reg, dt);
        systems.movementSystem(&reg, dt);
        systems.collisionSystem(&reg);

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.drawFPS(width - 100, 10);
        rl.clearBackground(.black);

        debug("Loop Completed, dt: {}", .{dt});

        systems.renderSystem(&reg);
    }
}

fn createPlayer(reg: *ecs.Registry, width: f32, _: f32) void {
    const entity = reg.create();
    reg.add(entity, comp.Position.new(width / 2, 10));
    reg.add(entity, comp.Velocity.new(0, 0));
    reg.add(entity, comp.Size.new(25, 40));
    reg.add(entity, comp.Colour.new(255, 255, 255, 255));
    reg.add(entity, comp.Jump{});
    reg.add(entity, comp.Grounded{});
    reg.add(entity, comp.PlayerTag{});
    reg.add(entity, comp.GravityTag{});
    reg.add(entity, comp.RenderTag{});
}

test "serialise level" {
    var rects = [_]Rect{
        .{ .x = 0, .y = 460, .width = 800, .height = 30 },
        .{ .x = -10, .y = 0, .width = 40, .height = 500, .render = false },
        .{ .x = 770, .y = 0, .width = 40, .height = 500, .render = false },
        .{ .x = 500, .y = 420, .width = 200, .height = 500 },
        .{ .x = 0, .y = 385, .width = 300, .height = 500 },
    };

    var level = Level{
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
