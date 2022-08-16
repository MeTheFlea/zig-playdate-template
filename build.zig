const std = @import("std");
const playdate_build = @import("zig-playdate-build.zig");

pub fn build(b: *std.build.Builder) !void {
    // https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads
    const arm_toolchain_path = std.os.getenv("ARM_TOOLCHAIN_PATH") orelse "";
    // https://play.date/dev/
    const playdate_sdk_path = std.os.getenv("PLAYDATE_SDK_PATH") orelse "";
    const libc_txt_path = "libs/zig-playdate/playdate-libc.txt";

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const zig_playdate_pkg = std.build.Pkg{ .name = "zig-playdate", .source = .{ .path = "libs/zig-playdate/src/main.zig" } };
    const game_name = "zig-playdate-template";
    const lib = playdate_build.createLib(game_name, "src/main.zig", b, playdate_sdk_path, arm_toolchain_path, libc_txt_path);
    lib.setBuildMode(mode);
    lib.addPackage(zig_playdate_pkg);
    lib.install();

    const game_elf = playdate_build.createElf(b, lib, playdate_sdk_path, arm_toolchain_path, libc_txt_path);
    game_elf.setBuildMode(mode);
    game_elf.install();

    const skip_simulator_option = b.option(bool, "skip-simulator", "skip building for the simulator") orelse false;
    const simulator_target: ?std.zig.CrossTarget = if (skip_simulator_option) null else std.zig.CrossTarget{
        .cpu_arch = .x86_64,
        .os_tag = .windows,
    };
    if (simulator_target == null) {
        std.log.info("skipping simulator build", .{});
    }
    if (playdate_build.setupPDC(b, game_elf, lib, playdate_sdk_path, arm_toolchain_path, game_name, .{}, simulator_target)) |simulator_lib| {
        simulator_lib.setBuildMode(mode);
        simulator_lib.addPackage(zig_playdate_pkg);
    }
}
