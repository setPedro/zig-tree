const std = @import("std");

const DIR_ENTRY = "├── ";
const DIR_GAP = "│   ";
const FILE_ENTRY = "└── ";

/// A simple program to display the folder and file structure of a directory in a readable way
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Get command line arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Use provided path or default to current directory
    const path = if (args.len > 1) args[1] else ".";

    // Start with an empty line for cleaner output
    std.debug.print("\n", .{});
    try iterateDir(allocator, path);
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

        const indent_level = try countPathDepth(_path);

        // TODO: dynamically calculate the correct indentation level, accounting for the current depth
        const gap = try repeatString(allocator, DIR_GAP, (indent_level - 1));
        defer allocator.free(gap);

        const entry_symbol = if (entry.kind == .directory) DIR_ENTRY else FILE_ENTRY;
        const name_with_suffix = if (entry.kind == .directory) try std.fmt.allocPrint(allocator, "{s}/", .{entry.name}) else entry.name;
        defer if (entry.kind == .directory) allocator.free(name_with_suffix);

        std.debug.print("{s}{s}{s}\n", .{ gap, entry_symbol, name_with_suffix });

        if (entry.kind == .directory) {
            try iterateDir(allocator, _path);
        }
    }
}

fn lessThan(_: void, lhs: std.fs.Dir.Entry, rhs: std.fs.Dir.Entry) bool {
    if (lhs.kind != rhs.kind) {
        return lhs.kind == .directory;
    }

    return std.mem.lessThan(u8, lhs.name, rhs.name);
}

/// Counts the number of `/` and returns nesting level
fn countPathDepth(path: []u8) !u8 {
    var level: u8 = 0;
    for (path) |char| {
        if (char == '/') {
            level += 1;
        }
    }

    return level;
}

fn repeatString(allocator: std.mem.Allocator, string: []const u8, multiplier: usize) ![]const u8 {
    var result = std.ArrayList(u8).init(allocator);
    defer result.deinit();

    for (0..multiplier) |_| {
        try result.appendSlice(string);
    }

    return result.toOwnedSlice();
}
