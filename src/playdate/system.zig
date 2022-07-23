const playdate = @import("playdate.zig");
const c = playdate.c;
const std = @import("std");

// Miscellaneous
// https://sdk.play.date/1.12.2/Inside%20Playdate%20with%20C.html#_miscellaneous
pub fn drawFps(x: i32, y: i32) void {
    playdate.api.system.*.drawFPS.?(x, y);
}
pub fn getCurrentTimeMilliseconds() u32 {
    return playdate.api.system.*.getCurrentTimeMilliseconds.?();
}

// Logging
// https://sdk.play.date/1.12.2/Inside%20Playdate%20with%20C.html#_logging
pub fn @"error"(message: []const u8) void {
    const cstr_message = std.cstr.addNullByte(playdate.allocator, message) catch unreachable;
    defer playdate.allocator.free(cstr_message);

    playdate.api.system.*.@"error".?(@ptrCast([*c]const u8, cstr_message));
}
pub fn logToConsole(message: []const u8) void {
    const cstr_message = std.cstr.addNullByte(playdate.allocator, message) catch unreachable;
    defer playdate.allocator.free(cstr_message);

    playdate.api.system.*.logToConsole.?(@ptrCast([*c]const u8, cstr_message));
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

// Interacting with the System Menu
// https://sdk.play.date/1.12.2/Inside%20Playdate%20with%20C.html#_interacting_with_the_system_menu
pub const MenuItem = anyopaque;

const CallbackWrapper = struct {
    var callback: fn () void = undefined;

    fn call() callconv(.C) void {
        callback();
    }
};

const S = struct {
    var counter_to_userdata = std.AutoArrayHashMap(usize, UserdataWrapper).init(playdate.allocator);
    var menu_item_to_counter = std.AutoArrayHashMap(*MenuItem, usize).init(playdate.allocator);
    var counter: usize = 0;
};
pub fn addMenuItem(title: []const u8, callback: fn (userdata: ?*anyopaque) void, userdata: ?*anyopaque) !*MenuItem {
    const cstr_title = try std.cstr.addNullByte(playdate.allocator, title);
    defer playdate.allocator.free(cstr_title);

    var userdata_wrapper = UserdataWrapper{
        .callback = callback,
        .userdata = userdata,
    };
    const ptr = @ptrCast(*MenuItem, playdate.api.system.*.addMenuItem.?(@ptrCast([*c]const u8, cstr_title), callbackWrapper, @intToPtr(?*anyopaque, S.counter)));

    try S.counter_to_userdata.put(S.counter, userdata_wrapper);
    try S.menu_item_to_counter.put(ptr, S.counter);
    S.counter += 1;

    return ptr;
}
pub fn addCheckmarkMenuItem(title: []const u8, value: bool, callback: fn (userdata: ?*anyopaque) void, userdata: ?*anyopaque) !*MenuItem {
    const cstr_title = try std.cstr.addNullByte(playdate.allocator, title);
    defer playdate.allocator.free(cstr_title);

    var userdata_wrapper = UserdataWrapper{
        .callback = callback,
        .userdata = userdata,
    };
    const ptr = @ptrCast(*anyopaque, playdate.api.system.*.addCheckmarkMenuItem.?(@ptrCast([*c]const u8, title), if (value) 1 else 0, callbackWrapper, @intToPtr(?*anyopaque, S.counter)));

    try S.counter_to_userdata.put(S.counter, userdata_wrapper);
    try S.menu_item_to_counter.put(ptr, S.counter);
    S.counter += 1;

    return ptr;
}

pub fn addOptionsMenuItem(title: []const u8, options: []const [*:0]const u8, callback: fn (userdata: ?*anyopaque) void, userdata: ?*anyopaque) !*MenuItem {
    const cstr_title = try std.cstr.addNullByte(playdate.allocator, title);
    defer playdate.allocator.free(cstr_title);

    var userdata_wrapper = UserdataWrapper{
        .callback = callback,
        .userdata = userdata,
    };

    const ptr = @ptrCast(*anyopaque, playdate.api.system.*.addOptionsMenuItem.?(@ptrCast([*c]const u8, cstr_title), @intToPtr([*c][*c]u8, @ptrToInt(options.ptr)), @intCast(c_int, options.len), callbackWrapper, @intToPtr(?*anyopaque, S.counter)));

    try S.counter_to_userdata.put(S.counter, userdata_wrapper);
    try S.menu_item_to_counter.put(ptr, S.counter);
    S.counter += 1;

    return ptr;
}
pub fn setMenuItemValue(menu_item: *MenuItem, value: i32) void {
    playdate.api.system.*.setMenuItemValue.?(@ptrCast(*c.PDMenuItem, menu_item), value);
}
pub fn getMenuItemValue(menu_item: *MenuItem) i32 {
    return playdate.api.system.*.getMenuItemValue.?(@ptrCast(*c.PDMenuItem, menu_item));
}
pub fn removeMenuItem(menu_item: *MenuItem) void {
    const counter = S.menu_item_to_counter.get(menu_item);
    S.menu_item_to_counter.swapRemove(menu_item);
    S.counter_to_userdata.swapRemove(counter);

    playdate.api.system.*.removeMenuItem.?(@ptrCast(*c.PDMenuItem, menu_item));
}
pub fn removeAllMenuItems() void {
    playdate.api.system.*.removeAllMenuItems.?();
}
const UserdataWrapper = struct { callback: fn (userdata: ?*anyopaque) void, userdata: ?*anyopaque };
fn callbackWrapper(userdata: ?*anyopaque) callconv(.C) void {
    const counter = @ptrToInt(userdata);
    const wrapper = S.counter_to_userdata.get(counter).?;
    wrapper.callback(wrapper.userdata);
}
