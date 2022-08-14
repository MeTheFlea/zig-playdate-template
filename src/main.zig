const std = @import("std");
const playdate = @import("zig-playdate");
const utils = @import("zig-playdate-utils");

export fn handleEvent(event: playdate.SystemEvent) void {
    _ = event;
    const str = utils.fmt.fmtTime(playdate.allocator, 150.0) catch unreachable;
    defer playdate.allocator.free(str);
    playdate.system.logToConsole(str);
}
export fn update() bool {
    playdate.graphics.clear(.White);
    return true;
}
