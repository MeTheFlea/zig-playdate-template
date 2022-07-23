const std = @import("std");
pub const c = @cImport({
    @cDefine("TARGET_PLAYDATE", "1");
    @cDefine("TARGET_EXTENSION", "1");
    @cInclude("pd_api.h");
});

pub const graphics = @import("graphics.zig");
pub const system = @import("system.zig");
pub const display = @import("display.zig");
pub const file = @import("file.zig");

pub const allocator = std.mem.Allocator{
    .ptr = undefined,
    .vtable = &@import("allocator.zig").vtable,
};

pub var api: *c.PlaydateAPI = undefined;

pub const SystemEvent = enum(usize) { Init, InitLua, Lock, Unlock, Pause, Resume, Terminate, KeyPressed, KeyReleased, LowPower };

export fn eventHandler(playdate_api: *c.PlaydateAPI, event: c.PDSystemEvent, arg: u32) callconv(.C) c_int {
    _ = playdate_api;
    _ = event;
    _ = arg;

    if (event == c.kEventInit) {
        api = playdate_api;
        api.system.*.setUpdateCallback.?(updateCallback, null);
    }

    handleEvent(@intToEnum(SystemEvent, event));

    return 0;
}

pub extern fn handleEvent(event: SystemEvent) void;
pub extern fn update() bool;

fn updateCallback(userdata: ?*anyopaque) callconv(.C) c_int {
    _ = userdata;

    if (update()) {
        return 1;
    } else {
        return 0;
    }
}
