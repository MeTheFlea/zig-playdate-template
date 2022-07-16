const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const game_name = "zig-game";

    // https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads
    const eabi_root = std.os.getenv("ARM_TOOLCHAIN_PATH") orelse return error.ARM_TOOLCHAIN_PATH_NOT_SET;
    const eabi_features = "v7e-m+fp/hard/";

    // https://play.date/dev/
    const playdate_sdk_path = std.os.getenv("PLAYDATE_SDK_PATH") orelse return error.PLAYDATE_SDK_PATH_NOT_SET;

    const mode = b.standardReleaseOptions();
    const output_path = try std.fs.path.join(b.allocator, &.{ b.install_path, "Source" });

    // from https://gist.github.com/DanB91/4236e82025bb21f2a0d7d72482e391d8
    const playdate_target = try std.zig.CrossTarget.parse(.{
        .arch_os_abi = "thumb-freestanding-eabihf",
        .cpu_features = "cortex_m7-fp64-fp_armv8d16-fpregs64-vfp2-vfp3d16-vfp4d16",
    });

    const lib = b.addSharedLibrary("pdex", "src/main.zig", .unversioned);
    try setupCommon(b, lib, mode, playdate_sdk_path, eabi_features, eabi_root, playdate_target);
    lib.setOutputDir(output_path);
    lib.install();

    const game_elf = b.addExecutable("pdex.elf", null);
    try setupCommon(b, game_elf, mode, playdate_sdk_path, eabi_features, eabi_root, playdate_target);
    game_elf.setOutputDir(b.install_path);
    game_elf.addObjectFile(try std.fs.path.join(b.allocator, &.{ output_path, "pdex.o" }));
    game_elf.step.dependOn(&lib.step);
    const c_args = [_][]const u8{
        "-DTARGET_PLAYDATE=1",
        "-DTARGET_EXTENSION=1",
    };
    game_elf.addCSourceFile(try std.fs.path.join(b.allocator, &.{ playdate_sdk_path, "/C_API/buildsupport/setup.c" }), &c_args);
    game_elf.install();

    const pdc_step = b.addSystemCommand(&.{ "bash", "-c", try std.fmt.allocPrint(b.allocator, "{s}/bin/pdc -sdkpath {0s} --skip-unknown {1s} zig-out/{2s}.pdx", .{ playdate_sdk_path, output_path, game_name }) });

    pdc_step.step.dependOn(&game_elf.step);
    b.getInstallStep().dependOn(&pdc_step.step);

    const playdate_copy_step = b.addSystemCommand(&.{ "bash", "-c", try std.fmt.allocPrint(b.allocator, "mv {0s}/libpdex.so {0s}/pdex.so && {1s}/arm-none-eabi/bin/objcopy -O binary zig-out/pdex.elf {0s}/pdex.bin", .{ output_path, eabi_root }) });
    pdc_step.step.dependOn(&playdate_copy_step.step);

    const copy_assets_step = b.addSystemCommand(&.{ "bash", "-c", try std.fmt.allocPrint(b.allocator, "mkdir -p {0s}/assets && cp -r assets/* {0s}/assets", .{output_path}) });
    pdc_step.step.dependOn(&copy_assets_step.step);

    if (!b.is_release) {
        const simulator_lib = b.addSharedLibrary("pdex", "src/main.zig", .unversioned);

        simulator_lib.setOutputDir(output_path);
        simulator_lib.setBuildMode(mode);
        simulator_lib.setTarget(std.zig.CrossTarget{
            .cpu_arch = .x86_64,
            .os_tag = .windows,
        });

        simulator_lib.addIncludeDir(try std.fs.path.join(b.allocator, &.{ playdate_sdk_path, "C_API" }));
        simulator_lib.linkLibC();
        simulator_lib.install();

        pdc_step.step.dependOn(&simulator_lib.step);
    }
}

pub fn setupCommon(b: *std.build.Builder, step: *std.build.LibExeObjStep, mode: std.builtin.Mode, playdate_sdk_path: []const u8, eabi_features: []const u8, eabi_root: []const u8, playdate_target: std.zig.CrossTarget) !void {
    step.setBuildMode(mode);

    step.setLinkerScriptPath(.{ .path = try std.fs.path.join(b.allocator, &.{ playdate_sdk_path, "/C_API/buildsupport/link_map.ld" }) });
    step.addIncludeDir(try std.fs.path.join(b.allocator, &.{ eabi_root, "/arm-none-eabi/include" }));
    step.addLibPath(try std.fs.path.join(b.allocator, &.{ eabi_root, "/lib/gcc/arm-none-eabi/11.2.1/thumb/", eabi_features }));
    step.addLibPath(try std.fs.path.join(b.allocator, &.{ eabi_root, "/arm-none-eabi/lib/thumb/", eabi_features }));

    step.addIncludeDir(try std.fs.path.join(b.allocator, &.{ playdate_sdk_path, "C_API" }));
    step.setLibCFile(std.build.FileSource{ .path = "./libc-files.txt" });

    step.setTarget(playdate_target);

    step.omit_frame_pointer = true;
    step.link_function_sections = true;
    step.stack_size = 61800;
}
