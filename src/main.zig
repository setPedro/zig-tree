const std = @import("std");

/// A simple program to display the folder and file structure of a directory in a readable way
pub fn main() !void {
    const cwd = std.fs.cwd();
    var dir = try cwd.openDir(".", .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |entry| {
        std.debug.print("{s}\n", .{entry.name});
    }
}
