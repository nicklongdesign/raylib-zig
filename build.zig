// raylib-zig (c) Nikolas Wipper 2020-2023

const std = @import("std");
const Builder = std.build.Builder;

const Program = struct {
    name: []const u8,
    path: []const u8,
    desc: []const u8,
};

pub fn getArtifact(b: *std.Build, target: std.zig.CrossTarget, optimize: std.builtin.Mode) *std.Build.Step.Compile {
    const raylib = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    });

    return raylib.artifact("raylib");
}

pub fn getModule(b: *std.Build) *std.Build.Module {
    return b.addModule("raylib", .{ .source_file = .{ .path = "lib/raylib-zig.zig" } });
}

pub const math = struct {
    pub fn getModule(b: *std.Build) *std.Build.Module {
        return b.addModule("raylib-math", .{ .source_file = .{ .path = "lib/raylib-zig-math.zig" } });
    }
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const examples = [_]Program{
        .{
            .name = "basic_window",
            .path = "examples/core/basic_window.zig",
            .desc = "Creates a basic window with text",
        },
        .{
            .name = "input_keys",
            .path = "examples/core/input_keys.zig",
            .desc = "Simple keyboard input",
        },
        .{
            .name = "input_mouse",
            .path = "examples/core/input_mouse.zig",
            .desc = "Simple mouse input",
        },
        .{
            .name = "input_mouse_wheel",
            .path = "examples/core/input_mouse_wheel.zig",
            .desc = "Mouse wheel input",
        },
        .{
            .name = "input_multitouch",
            .path = "examples/core/input_multitouch.zig",
            .desc = "Multitouch input",
        },
        .{
            .name = "2d_camera",
            .path = "examples/core/2d_camera.zig",
            .desc = "Shows the functionality of a 2D camera",
        },
        .{
            .name = "3d_camera_first_person",
            .path = "examples/core/3d_camera_first_person.zig",
            .desc = "Simple first person demo",
        },
        .{
            .name = "texture_outline",
            .path = "examples/shaders/texture_outline.zig",
            .desc = "Uses a shader to create an outline around a sprite",
        },
        .{
            .name = "logo_raylib",
            .path = "examples/shapes/logo_raylib.zig",
            .desc = "Renders the raylib-zig logo",
        },
        .{
            .name = "sprite_anim",
            .path = "examples/textures/sprite_anim.zig",
            .desc = "Animate a sprite",
        },
        // .{
        //     .name = "models_loading",
        //     .path = "examples/models/models_loading.zig",
        //     .desc = "Loads a model and renders it",
        // },
        // .{
        //     .name = "shaders_basic_lighting",
        //     .path = "examples/shaders/shaders_basic_lighting.zig",
        //     .desc = "Loads a model and renders it",
        // },
    };

    const examples_step = b.step("examples", "Builds all the examples");
    const system_lib = b.option(bool, "system-raylib", "link to preinstalled raylib libraries") orelse false;
    _ = system_lib;

    var raylib = getModule(b);
    var raylib_math = math.getModule(b);
    var raylib_artifact = getArtifact(b, target, optimize);

    for (examples) |ex| {
        const exe = b.addExecutable(.{ .name = ex.name, .root_source_file = .{ .path = ex.path }, .optimize = optimize, .target = target });

        exe.linkLibrary(raylib_artifact);
        exe.addModule("raylib", raylib);
        exe.addModule("raylib-math", raylib_math);

        const run_cmd = b.addRunArtifact(exe);
        const run_step = b.step(ex.name, ex.desc);
        run_step.dependOn(&run_cmd.step);
        examples_step.dependOn(&exe.step);
    }
}
