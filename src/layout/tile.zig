const Self = @This();

const std = @import("std");
const log = std.log.scoped(.tiled);

const utils = @import("../utils.zig");
const config = @import("../config.zig");
const Context = @import("../context.zig");
const Output = @import("../output.zig");
const Window = @import("../window.zig");


nmaster: i32,
mfact: f32,
gap: i32,
master_location: enum {
    left,
    right,
    top,
    bottom,
},


pub fn arrange(self: *const Self, output: *Output) void {
    log.debug("<{*}> arrange windows in output {*}", .{ self, output });

    const context = Context.get();

    var windows: std.ArrayList(*Window) = .empty;
    defer windows.deinit(utils.allocator);
    {
        var it = context.windows.safeIterator(.forward);
        while (it.next()) |window| {
            if (
                !window.is_visible_in(output)
                or window.floating
            ) continue;
            windows.append(utils.allocator, window) catch |err| {
                log.debug("<{*}> append window failed: {}", .{ self, err });
                return;
            };
        }
    }

    if (windows.items.len == 0) return;

    const width, const height = switch (self.master_location) {
        .left, .right => .{ output.width, output.height },
        .top, .bottom => .{ output.height, output.width },
    };

    var master_width: i32 = undefined;
    var master_height: i32 = undefined;
    var master_remain: i32 = undefined;
    var stack_width: i32 = undefined;
    var stack_height: i32 = undefined;
    var stack_remain: i32 = undefined;

    const window_num: i32 = @intCast(windows.items.len);
    const nstack = window_num - self.nmaster;
    if (nstack > 0) {
        const available_width = width -| 3*self.gap -| 4*config.border_width;

        master_width = @intFromFloat(self.mfact * @as(f32, @floatFromInt(available_width)));
        stack_width = available_width - master_width;

        var available_height: i32 = undefined;

        available_height = height -| (self.nmaster+1)*self.gap -| 2*self.nmaster*config.border_width;
        master_height = @divFloor(available_height, self.nmaster);
        master_remain = @mod(available_height, self.nmaster);

        available_height = height -| (nstack+1)*self.gap -| 2*nstack*config.border_width;
        stack_height = @divFloor(available_height, nstack);
        stack_remain = @mod(available_height, nstack);
    } else {
        const available_width = width -| 2*self.gap -| 2*config.border_width;
        const available_height = height -| (self.nmaster+1)*self.gap -| 2*self.nmaster*config.border_width;
        master_width = available_width;
        master_height = @divFloor(available_height, self.nmaster);
        master_remain = @mod(available_height, self.nmaster);
    }

    const step = self.gap + 2*config.border_width;
    const master_x = self.gap + config.border_width;
    const stack_x = master_x + master_width + step;
    var master_y = self.gap + config.border_width;
    var stack_y = self.gap + config.border_width;
    for (0.., windows.items) |i, window| {
        var x: i32 = undefined;
        var y: i32 = undefined;
        var w: i32 = undefined;
        var h: i32 = undefined;
        if (i < self.nmaster) {
            x = master_x;
            y = master_y;
            w = master_width;
            h = master_height + if (i == 0) master_remain else 0;
            master_y += master_height + step;
        } else {
            x = stack_x;
            y = stack_y;
            w = stack_width;
            h = stack_height + if (i == nstack) stack_remain else 0;
            stack_y += stack_height + step;
        }

        switch (self.master_location) {
            .left => {
                window.move(x, y);
                window.resize(w, h);
            },
            .right => {
                window.move(width-x-w, y);
                window.resize(w, h);
            },
            .top => {
                window.move(y, x);
                window.resize(h, w);
            },
            .bottom => {
                window.move(y, width-x-w);
                window.resize(h, w);
            }
        }
    }
}
