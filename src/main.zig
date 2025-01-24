const std = @import("std");

/// A simple program to display the folder and file structure of a directory in a readable way
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    try iterateDir(allocator, ".");
}

fn iterateDir(allocator: std.mem.Allocator, path: []const u8) !void {
    const cwd = std.fs.cwd();
    var dir = try cwd.openDir(path, .{});
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |entry| {
        if (entry.name[0] == '.') continue;

        if (entry.kind == .directory) {
            std.debug.print("dir: {s}\n", .{entry.name});

            const _path = try std.mem.concat(allocator, u8, &[_][]const u8{ path, "/", entry.name });

            defer allocator.free(_path);
            std.debug.print("PATH: {s}\n", .{_path});

            try iterateDir(allocator, _path);
        }
    }
}
