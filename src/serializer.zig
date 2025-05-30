const std = @import("std");
const json = std.json;
const Level = @import("level.zig").Level;
const Rect = @import("level.zig").Rect;
const log = @import("log.zig");

pub fn readJsonFile(allocator: std.mem.Allocator, file_path: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    // Get file size
    const file_size = (try file.stat()).size;

    // Allocate buffer for file content
    const buffer = try allocator.alloc(u8, file_size);
    errdefer allocator.free(buffer);

    // Read entire file
    const bytes_read = try file.readAll(buffer);
    if (bytes_read != file_size) {
        return error.UnexpectedEndOfFile;
    }

    return buffer;
}

pub fn writeJsonFile(file_path: []const u8, json_str: []const u8) !void {
    const file = try std.fs.cwd().createFile(file_path, .{});
    defer file.close();
    try file.writeAll(json_str);
}

pub fn serialiseLevel(level: *Level) ![]const u8 {
    return json.stringifyAlloc(std.heap.page_allocator, level, .{
        .emit_null_optional_fields = false,
    });
}

pub fn deserialiseLevel(str: []const u8) !Level {
    var parser = json.parseFromSliceLeaky(
        json.Value,
        std.heap.page_allocator,
        str,
        .{},
    ) catch unreachable;

    const array = parser.object.get("rects").?.array;
    const name = parser.object.get("name").?.string;
    const start_x = parser.object.get("start_x").?.integer;
    const start_y = parser.object.get("start_y").?.integer;

    const rects = try std.heap.page_allocator.alloc(Rect, array.items.len);

    for (array.items, 0..) |item, i| {
        const obj = item.object;
        rects[i] = .{
            .x = @floatCast(obj.get("x").?.float),
            .y = @floatCast(obj.get("y").?.float),
            .width = @floatCast(obj.get("width").?.float),
            .height = @floatCast(obj.get("height").?.float),
            .render = obj.get("render").?.bool,
        };
    }

    log.debug("New Level: {s}", .{name});

    return Level{
        .name = name,
        .start_x = @intCast(start_x),
        .start_y = @intCast(start_y),
        .rects = rects,
    };
}
