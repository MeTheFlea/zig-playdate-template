const std = @import("std");

const playdate_build = @import("zig-playdate-build.zig");

const zig_playdate_pkg = std.build.Pkg{ .name = "zig-playdate", .source = .{ .path = "libs/zig-playdate/src/main.zig" } };

pub fn build(b: *std.build.Builder) !void {
    // https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads
    const arm_toolchain_path = std.os.getenv("ARM_TOOLCHAIN_PATH") orelse "";
    // https://play.date/dev/
    const playdate_sdk_path = std.os.getenv("PLAYDATE_SDK_PATH") orelse "";

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const game_name = "zig-playdate-template";
    const lib = playdate_build.createLib(game_name, "src/main.zig", b, playdate_sdk_path, arm_toolchain_path);
    setupZigCommon(b, lib, mode);
    lib.install();

    const game_elf = playdate_build.createElf(b, lib, playdate_sdk_path, arm_toolchain_path);
    game_elf.setBuildMode(mode);
    game_elf.install();

    const simulator_target: ?std.zig.CrossTarget = if (b.is_release) null else std.zig.CrossTarget{
        .cpu_arch = .x86_64,
        .os_tag = .windows,
    };
    if (playdate_build.setupPDC(b, game_elf, lib, playdate_sdk_path, arm_toolchain_path, game_name, .{}, simulator_target)) |simulator_lib| {
        setupZigCommon(b, simulator_lib, mode);
    }
}

pub fn setupZigCommon(b: *std.build.Builder, step: *std.build.LibExeObjStep, mode: std.builtin.Mode) void {
    _ = b;
    step.setBuildMode(mode);

    step.addPackage(zig_playdate_pkg);
}
