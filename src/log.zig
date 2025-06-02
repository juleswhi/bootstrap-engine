const std = @import("std");
const rl = @import("raylib");

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
        .debug => .{ .prefix = "DEBUG", .color = "\x1b[36m" },
        .info  => .{ .prefix = "INFO ", .color = "\x1b[32m" },
        .warn  => .{ .prefix = "WARN ", .color = "\x1b[33m" },
        .err   => .{ .prefix = "ERROR", .color = "\x1b[31m" },
        .fatal => .{ .prefix = "FATAL", .color = "\x1b[1;31m" },
    };

    const stderr = std.io.getStdErr().writer();

    stderr.print("{} :: {s}[{s}]\x1b[38;5;15m ", .{rl.getTime(), level_info.color, level_info.prefix}) catch return;

    stderr.print(fmt, args) catch return;
    stderr.writeAll("\x1b[0m\n") catch {};
}

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

