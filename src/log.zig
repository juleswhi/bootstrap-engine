const std = @import("std");

pub const LogLevel = enum {
    debug,
    info,
    warn,
    err,
    fatal,
};

pub fn log(
    comptime level: LogLevel,
    comptime fmt: []const u8,
    args: anytype,
) void {
    const level_info = switch (level) {
        .debug => .{ .prefix = "DEBUG", .color = "\x1b[36m" }, // Cyan
        .info  => .{ .prefix = "INFO ", .color = "\x1b[32m" }, // Green
        .warn  => .{ .prefix = "WARN ", .color = "\x1b[33m" }, // Yellow
        .err   => .{ .prefix = "ERROR", .color = "\x1b[31m" }, // Red
        .fatal => .{ .prefix = "FATAL", .color = "\x1b[1;31m" }, // Bold Red
    };

    const stderr = std.io.getStdErr().writer();

    // Print colored prefix
    stderr.print("{s}[{s}] ", .{level_info.color, level_info.prefix}) catch return;

    // Print user message with formatting
    stderr.print(fmt, args) catch return;

    // Reset color and add newline
    stderr.writeAll("\x1b[0m\n") catch {};
}

// Optional: Convenience functions for each log level
pub fn debug(comptime fmt: []const u8, args: anytype) void {
    log(.debug, fmt, args);
}

pub fn info(comptime fmt: []const u8, args: anytype) void {
    log(.info, fmt, args);
}

pub fn warn(comptime fmt: []const u8, args: anytype) void {
    log(.warn, fmt, args);
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    log(.err, fmt, args);
}

pub fn fatal(comptime fmt: []const u8, args: anytype) void {
    log(.fatal, fmt, args);
}
