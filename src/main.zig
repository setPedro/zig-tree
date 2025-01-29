const std = @import("std");

const DIR_ENTRY = "├── ";
const DIR_GAP = "│   ";
const FILE_ENTRY = "└── ";

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
        const _path = try std.fs.path.join(allocator, &.{ path, entry.name });
        defer allocator.free(_path);

        const result = try formatPath(_path);
        const indent_level = result[0];
        const formatted_path = result[1];

        const gap = try repeatString(allocator, DIR_GAP, (indent_level - 2));
        defer allocator.free(gap);

        if (entry.kind == .directory) {
            std.debug.print("{s}{s}{s}\n", .{ gap, DIR_ENTRY, formatted_path });

            try iterateDir(allocator, _path);
        }

        if (entry.kind == .file) {
            std.debug.print("{s}{s}{s}\n", .{ gap, FILE_ENTRY, formatted_path });
        }
    }
}

fn lessThan(_: void, lhs: std.fs.Dir.Entry, rhs: std.fs.Dir.Entry) bool {
    if (lhs.kind != rhs.kind) {
        return lhs.kind == .directory;
    }

    return std.mem.lessThan(u8, lhs.name, rhs.name);
}

fn formatPath(path: []u8) !struct { u8, []u8 } {
    var level: u8 = 0;
    var formatted_path: []u8 = "";
    for (path, 0..) |char, i| {
        if (char == '/') {
            formatted_path = path[i + 1 ..];
            level += 1;
        }
    }

    return .{ level, formatted_path };
}

fn repeatString(allocator: std.mem.Allocator, string: []const u8, multiplier: usize) ![]const u8 {
    var result = std.ArrayList(u8).init(allocator);
    defer result.deinit();

    for (0..multiplier) |_| {
        try result.appendSlice(string);
    }

    return result.toOwnedSlice();
}
