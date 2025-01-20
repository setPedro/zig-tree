const std = @import("std");

/// A simple program to display the folder and file structure of a directory in a readable way
pub fn main() !void {
    try iterateDir(".");
}

fn iterateDir(path: []const u8) !void {
    const cwd = std.fs.cwd();
    var dir = try cwd.openDir(path, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |entry| {
        const kind = entry.kind;

        if (kind == std.fs.File.Kind.directory and entry.name[0] != '.') {
            std.debug.print("I'M A DIRECTORY: {s}\n", .{entry.name});
        }

        std.debug.print("{s}\n", .{entry.name});
    }
}
