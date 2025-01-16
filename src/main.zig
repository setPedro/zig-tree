const std = @import("std");

pub fn main() !void {
    var args_iterator = std.process.args();

    while (args_iterator.next()) |arg| {
        std.debug.print("Hello, {s}!\n", .{arg});
    }
}
