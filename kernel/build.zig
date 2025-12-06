const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    const Target = std.Target.x86;
    const target = b.resolveTargetQuery(.{
        .abi = .none,
        .cpu_features_sub = Target.featureSet(&.{ .sse, .sse2, .avx, .avx2, .mmx }),
        .cpu_features_add = Target.featureSet(&.{ .popcnt, .soft_float }),
        .os_tag = .freestanding,
        .cpu_arch = .x86_64,
    });

    const exe = b.addExecutable(.{
        .name = "kernel.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .red_zone = false,
            .code_model = .kernel,
        }),
    });

    exe.setLinkerScript(b.path("linker.ld"));

    exe.entry = .{ .symbol_name = "start" };
    exe.root_module.addObjectFile(b.path("boot/header.o"));
    exe.root_module.addObjectFile(b.path("boot/main.o"));
    exe.root_module.addObjectFile(b.path("boot/main64.o"));

    const header_obj = b.addSystemCommand(&.{ "nasm", "-f", "elf64", "-o", "boot/header.o", "boot/header.asm" });
    const main_obj = b.addSystemCommand(&.{ "nasm", "-f", "elf64", "-o", "boot/main.o", "boot/main.asm" });
    const main64_obj = b.addSystemCommand(&.{ "nasm", "-f", "elf64", "-o", "boot/main64.o", "boot/main64.asm" });

    exe.step.dependOn(&header_obj.step);
    exe.step.dependOn(&main_obj.step);
    exe.step.dependOn(&main64_obj.step);

    b.installArtifact(exe);
}
