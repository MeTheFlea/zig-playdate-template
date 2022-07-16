const playdate = @import("playdate.zig");
const c = playdate.c;
const std = @import("std");

pub const vtable = std.mem.Allocator.VTable{
    .alloc = alloc,
    .resize = resize,
    .free = free,
};

fn alloc(_: *anyopaque, len: usize, ptr_align: u29, len_align: u29, ret_addr: usize) error{OutOfMemory}![]u8 {
    _ = ptr_align;
    _ = len_align;
    _ = ret_addr;

    const ptr = playdate.api.system.*.realloc.?(null, len);
    if (ptr == null) {
        return error.OutOfMemory;
    }
    return @ptrCast([*]u8, ptr)[0..len];
}

fn resize(
    ptr: *anyopaque,
    buf: []u8,
    buf_align: u29,
    new_len: usize,
    len_align: u29,
    ret_addr: usize,
) ?usize {
    _ = ptr;
    _ = buf;
    _ = buf_align;
    _ = new_len;
    _ = len_align;
    _ = ret_addr;

    return null;
}

fn free(ptr: *anyopaque, buf: []u8, buf_align: u29, ret_addr: usize) void {
    _ = ptr;
    _ = buf_align;
    _ = ret_addr;

    _ = playdate.api.system.*.realloc.?(buf.ptr, 0);
}
