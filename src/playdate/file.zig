const playdate = @import("playdate.zig");
const c = playdate.c;
const std = @import("std");

// Filesystem
// https://sdk.play.date/1.12.2/Inside%20Playdate%20with%20C.html#_filesystem
pub fn geterr() []const u8 {
    const err = playdate.api.file.*.geterr.?();
    return std.mem.sliceTo(err, 0);
}
pub fn listfiles(path: []const u8, callback: fn (filename: []const u8, userdata: ?*anyopaque) void, userdata: ?*anyopaque, show_hidden: bool) !void {
    const c_str = try std.cstr.addNullByte(playdate.allocator, path);
    defer playdate.allocator.free(c_str);

    var userdata_wrapper = UserdataWrapper{
        .callback = callback,
        .userdata = userdata,
    };
    const val = playdate.api.file.*.listfiles.?(c_str, callbackWrapper, @ptrCast(*anyopaque, &userdata_wrapper), if (show_hidden) 1 else 0);
    if (val != 0) {
        return error.ListFilesError;
    }
}

const UserdataWrapper = struct { callback: fn (filename: []const u8, userdata: ?*anyopaque) void, userdata: ?*anyopaque };
fn callbackWrapper(filename: [*c]const u8, userdata: ?*anyopaque) callconv(.C) void {
    const wrapper = @ptrCast(*UserdataWrapper, @alignCast(@alignOf(*UserdataWrapper), userdata));
    wrapper.callback(std.mem.sliceTo(filename, 0), wrapper.userdata);
}
