const playdate = @import("playdate.zig");
const c = playdate.c;
const std = @import("std");

// Display
// https://sdk.play.date/1.12.1/Inside%20Playdate%20with%20C.html#_display
pub const ScaleFactor = enum(c_uint) {
    x1 = 1,
    x2 = 2,
    x4 = 4,
    x8 = 8,
};

pub fn getHeight() i32 {
    return playdate.api.display.*.getHeight.?();
}
pub fn getWidth() i32 {
    return playdate.api.display.*.getWidth.?();
}
pub fn setInverted(inverted: bool) void {
    playdate.api.display.*.setInverted.?(if (inverted) 1 else 0);
}
pub fn setScale(scale: ScaleFactor) void {
    playdate.api.display.*.setScale.?(@enumToInt(scale));
}
