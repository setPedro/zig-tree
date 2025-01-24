const std = @import("std");

/// A simple program to display the folder and file structure of a directory in a readable way
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    try iterateDir(allocator, "./mock");
}

fn iterateDir(allocator: std.mem.Allocator, path: []const u8) !void {
    const cwd = std.fs.cwd();
    var dir = try cwd.openDir(path, .{});
    defer dir.close();

    var entries = std.ArrayList(std.fs.Dir.Entry).init(allocator);
    defer entries.deinit();

    var iterator = dir.iterate();
    while (try iterator.next()) |entry| {
        if (entry.name[0] == '.') continue;
        try entries.append(entry);
    }

    std.mem.sort(std.fs.Dir.Entry, entries.items, {}, lessThan);

    for (entries.items) |entry| {
        if (entry.kind == .directory) {
            const _path = try std.fs.path.join(allocator, &.{ path, entry.name });

            defer allocator.free(_path);
            std.debug.print("PATH: {s}\n", .{_path});

            try iterateDir(allocator, _path);
        }

        if (entry.kind == .file) {
            std.debug.print("   {s}\n", .{entry.name});
        }
    }
}

fn lessThan(_: void, lhs: std.fs.Dir.Entry, rhs: std.fs.Dir.Entry) bool {
    if (lhs.kind != rhs.kind) {
        return lhs.kind == .directory;
    }

    return std.mem.lessThan(u8, lhs.name, rhs.name);
}
