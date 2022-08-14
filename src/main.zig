const std = @import("std");
const playdate = @import("zig-playdate");

export fn handleEvent(event: playdate.SystemEvent) void {
    std.log.info("EVENT: {any}", .{event});
}
export fn update() bool {
    playdate.graphics.clear(.White);
    playdate.system.drawFps(0, 0);
    playdate.graphics.drawText("hello world!", @divTrunc(playdate.display.getWidth(), 2), @divTrunc(playdate.display.getHeight(), 2));
    return true;
}

// Define root.log to override the std implementation
pub fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    playdate.log(level, scope, format, args);
}
