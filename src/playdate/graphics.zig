const playdate = @import("playdate.zig");
const c = playdate.c;
const std = @import("std");

pub const LCDColor = usize;
pub const LCDSolidColor = enum(c_int) { Black, White, Clear, XOR };

// Miscellaneous
// https://sdk.play.date/1.12.2/Inside%20Playdate%20with%20C.html#_miscellaneous_2
pub fn clear(color: LCDSolidColor) void {
    playdate.api.graphics.*.clear.?(@intCast(LCDColor, @enumToInt(color)));
}

// Fonts & Text
// https://sdk.play.date/1.12.2/Inside%20Playdate%20with%20C.html#_fonts_text
pub const LCDFont = anyopaque;

pub fn drawText(text: []const u8, x: i32, y: i32) void {
    _ = playdate.api.graphics.*.drawText.?(@ptrCast(*const anyopaque, text), text.len, c.kASCIIEncoding, x, y);
}
pub fn loadFont(path: []const u8) !*LCDFont {
    var err: [*c]const u8 = null;

    const cstr_path = std.cstr.addNullByte(playdate.allocator, path) catch unreachable;
    defer playdate.allocator.free(cstr_path);

    const font = playdate.api.graphics.*.loadFont.?(@ptrCast([*c]const u8, cstr_path), &err);

    if (err != null) {
        const error_message = std.fmt.allocPrint(playdate.allocator, "LoadFontError: {s}", .{std.mem.sliceTo(err, '0')}) catch unreachable;
        defer playdate.allocator.free(error_message);
        playdate.system.@"error"(error_message);
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

// Geometry
// https://sdk.play.date/1.12.2/Inside%20Playdate%20with%20C.html#_geometry
pub fn drawLine(x1: i32, y1: i32, x2: i32, y2: i32, width: i32, color: LCDSolidColor) void {
    playdate.api.graphics.*.drawLine.?(x1, y1, x2, y2, width, @enumToInt(color));
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
pub const BitmapData = struct { width: i32, height: i32, row_bytes: i32 };

pub fn loadBitmap(path: []const u8) !*LCDBitmap {
    var err: [*c]const u8 = null;

    const cstr_path = std.cstr.addNullByte(playdate.allocator, path) catch unreachable;
    defer playdate.allocator.free(cstr_path);

    const font = playdate.api.graphics.*.loadBitmap.?(@ptrCast([*c]const u8, cstr_path), &err);

    if (err != null) {
        const error_message = std.fmt.allocPrint(playdate.allocator, "LoadBitmapError: {s}", .{std.mem.sliceTo(err, '0')}) catch unreachable;
        defer playdate.allocator.free(error_message);
        playdate.system.@"error"(error_message);
        return error.LoadBitmapError;
    }

    return @ptrCast(*LCDFont, font);
}
pub fn freeBitmap(bitmap: *LCDBitmap) void {
    playdate.api.graphics.*.freeBitmap.?(@ptrCast(*c.LCDBitmap, bitmap));
}
pub fn drawBitmap(bitmap: *LCDBitmap, x: i32, y: i32, flip: LCDBitmapFlip) void {
    playdate.api.graphics.*.drawBitmap.?(@ptrCast(*c.LCDBitmap, bitmap), x, y, @enumToInt(flip));
}
pub fn drawScaledBitmap(bitmap: *LCDBitmap, x: i32, y: i32, x_scale: f32, y_scale: f32) void {
    playdate.api.graphics.*.drawScaledBitmap.?(@ptrCast(*c.LCDBitmap, bitmap), x, y, x_scale, y_scale);
}
pub fn rotatedBitmap(bitmap: *LCDBitmap, rotation: f32, x_scale: f32, y_scale: f32) *LCDBitmap {
    return @ptrCast(*LCDBitmap, playdate.api.graphics.*.rotatedBitmap.?(@ptrCast(*c.LCDBitmap, bitmap), rotation, x_scale, y_scale, null));
}
pub fn getBitmapData(bitmap: *LCDBitmap) BitmapData {
    var width: c_int = undefined;
    var height: c_int = undefined;
    var row_bytes: c_int = undefined;

    playdate.api.graphics.*.getBitmapData.?(@ptrCast(*c.LCDBitmap, bitmap), &width, &height, &row_bytes, null, null);

    return BitmapData{
        .width = @intCast(i32, width),
        .height = @intCast(i32, height),
        .row_bytes = @intCast(i32, row_bytes),
    };
}
