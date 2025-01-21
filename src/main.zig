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
            const max_len = 264;
            var buf: [max_len]u8 = undefined;

            const len = try std.fmt.bufPrint(&buf, "./{s}", .{entry.name});
            std.debug.print("dir: {s}\n", .{entry.name});
            const _path = buf[0..len.len];
            std.debug.print("PATH: {s}\n", .{_path});
        }
    }
}
