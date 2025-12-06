fn hcf() noreturn {
    while (true) {
        asm volatile ("hlt");
    }
}

const Character = packed struct(u16) {
    char: u8,
    flags: u8,

    pub fn init(flags: u8, char: u8) Character {
        return .{ .flags = flags, .char = char };
    }
};

const VIDEO_MEMORY: [*]volatile Character = @ptrFromInt(0xb8000);

pub export fn kernel_main() linksection(".text") noreturn {
    // VIDEO_MEMORY[4] = .init(0x2f, 0x4f);
    // VIDEO_MEMORY[5] = .init(0x2f, 0x4b);

    for (0..(80 * 25)) |i| {
        VIDEO_MEMORY[i] = .init(@intCast(i % 256), ' ');
    }

    hcf();
}
