const playdate = @import("playdate.zig");
const c = playdate.c;

// Miscellaneous
// https://sdk.play.date/1.12.2/Inside%20Playdate%20with%20C.html#_miscellaneous
pub fn drawFps(x: i32, y: i32) void {
    playdate.api.system.*.drawFPS.?(x, y);
}

// Logging
// https://sdk.play.date/1.12.2/Inside%20Playdate%20with%20C.html#_logging
pub fn @"error"(message: []const u8) void {
    playdate.api.system.*.@"error".?(@ptrCast([*c]const u8, message));
}
pub fn logToConsole(message: []const u8) void {
    playdate.api.system.*.logToConsole.?(@ptrCast([*c]const u8, message));
}

// Crank
// https://sdk.play.date/1.12.2/Inside%20Playdate%20with%20C.html#_crank
pub fn getCrankAngle() f32 {
    return playdate.api.system.*.getCrankAngle.?();
}
pub fn getCrankChange() f32 {
    return playdate.api.system.*.getCrankChange.?();
}
pub fn isCrankDocked() bool {
    return playdate.api.system.*.isCrankDocked.?() == 1;
}
