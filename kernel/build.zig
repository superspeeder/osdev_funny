const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    const Target = std.Target.x86;
    const target = b.resolveTargetQuery(.{
        .abi = .none,
        .cpu_features_sub = Target.featureSet(&.{ .sse, .sse2, .avx, .avx2, .mmx }),
        .cpu_features_add = Target.featureSet(&.{ .popcnt, .soft_float }),
        .os_tag = .freestanding,
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

    b.installArtifact(exe);
}
