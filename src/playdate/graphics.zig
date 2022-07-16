const playdate = @import("playdate.zig");
const c = playdate.c;
const std = @import("std");

pub const LCDSolidColor = enum(usize) { Black, White, Clear, XOR };

// Miscellaneous
// https://sdk.play.date/1.12.2/Inside%20Playdate%20with%20C.html#_miscellaneous_2
pub fn clear(color: LCDSolidColor) void {
    playdate.api.graphics.*.clear.?(@enumToInt(color));
}

// Fonts & Text
// https://sdk.play.date/1.12.2/Inside%20Playdate%20with%20C.html#_fonts_text
pub const LCDFont = anyopaque;

pub fn drawText(text: []const u8, x: i32, y: i32) void {
    _ = playdate.api.graphics.*.drawText.?(@ptrCast(*const anyopaque, text), text.len, c.kASCIIEncoding, x, y);
}
pub fn loadFont(path: []const u8) !*LCDFont {
    var err: [*c]const u8 = null;
    const font = playdate.api.graphics.*.loadFont.?(@ptrCast([*c]const u8, path), &err);

    if (err != null) {
        playdate.system.@"error"(std.fmt.allocPrint(playdate.allocator, "LoadFontError: {s}", .{std.mem.sliceTo(err, '0')}) catch unreachable);
        return error.LoadFontError;
    }

    return @ptrCast(*LCDFont, font);
}
pub fn setFont(font: *LCDFont) void {
    playdate.api.graphics.*.setFont.?(@ptrCast(*c.LCDFont, font));
}
pub fn getTextWidth(font: *LCDFont, text: []const u8) i32 {
    return playdate.api.graphics.*.getTextWidth.?(@ptrCast(*c.LCDFont, font), @ptrCast([*c]const u8, text), text.len, c.kASCIIEncoding, 0);
}
pub fn getFontHeight(font: *LCDFont) i32 {
    return playdate.api.graphics.*.getFontHeight.?(@ptrCast(*c.LCDFont, font));
}

// Bitmaps
// https://sdk.play.date/1.12.2/Inside%20Playdate%20with%20C.html#_bitmaps
pub const LCDBitmap = anyopaque;
pub const LCDBitmapFlip = enum {
    Unflipped,
    FlippedX,
    FlippedY,
    FlippedXY,
};

pub fn loadBitmap(path: []const u8) !*LCDBitmap {
    var err: [*c]const u8 = null;
    const font = playdate.api.graphics.*.loadBitmap.?(@ptrCast([*c]const u8, path), &err);

    if (err != null) {
        playdate.system.@"error"(std.fmt.allocPrint(playdate.allocator, "LoadBitmapError: {s}", .{std.mem.sliceTo(err, '0')}) catch unreachable);
        return error.LoadBitmapError;
    }

    return @ptrCast(*LCDFont, font);
}
pub fn freeBitmap(bitmap: *LCDBitmap) void {
    playdate.api.graphics.*.freeBitmap.?(bitmap);
}
pub fn drawBitmap(bitmap: *LCDBitmap, x: i32, y: i32, flip: LCDBitmapFlip) void {
    playdate.api.graphics.*.drawBitmap.?(@ptrCast(*c.LCDBitmap, bitmap), x, y, @enumToInt(flip));
}
pub fn drawScaledBitmap(bitmap: *LCDBitmap, x: i32, y: i32, x_scale: f32, y_scale: f32) void {
    playdate.api.graphics.*.drawScaledBitmap.?(@ptrCast(*c.LCDBitmap, bitmap), x, y, x_scale, y_scale);
}
