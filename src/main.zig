const playdate = @import("playdate/playdate.zig");
const std = @import("std");

var allocator = playdate.allocator;

var current_font: *playdate.graphics.LCDFont = undefined;

export fn handleEvent(event: playdate.SystemEvent) void {
    if (event == playdate.SystemEvent.Init) {
        current_font = playdate.graphics.loadFont("Roobert-24-Medium.pft") catch unreachable;
        playdate.graphics.setFont(current_font);
    }
}

export fn update() bool {
    const is_docked = playdate.system.isCrankDocked();
    playdate.display.setInverted(is_docked);
    playdate.graphics.clear(playdate.graphics.LCDSolidColor.White);
    playdate.system.drawFps(0, 0);

    const angle = playdate.system.getCrankAngle();
    const str: []u8 = if (is_docked) std.fmt.allocPrint(allocator, "{s}", .{"OPEN THE CRANK"}) catch unreachable else std.fmt.allocPrint(allocator, "{e}", .{angle}) catch unreachable;
    defer allocator.free(str);

    const width = playdate.display.getWidth();
    const height = playdate.display.getHeight();
    const font_width = playdate.graphics.getTextWidth(current_font, str);
    const font_height = playdate.graphics.getFontHeight(current_font);

    playdate.graphics.drawText(str, @divFloor(width, 2) - @divFloor(font_width, 2), @divFloor(height, 2) - @divFloor(font_height, 2));

    return true;
}
