const std = @import("std");
const posix = std.posix;

const types = @import("kwm/types.zig");
const Window = @import("kwm/window.zig");
const Context = @import("kwm/context.zig");

pub const layout = @import("kwm/layout.zig");
pub const binding = @import("kwm/binding.zig");
pub const WindowDecoration = Window.Decoration;
pub const State = types.State;
pub const Button = types.Button;
pub const KeyboardRepeatInfo = types.KeyboardRepeatInfo;
pub const KeyboardNumlockState = types.KeyboardNumlockState;
pub const KeyboardCapslockState = types.KeyboardCapslockState;
pub const KeyboardLayout = types.KeyboardLayout;
pub const Keymap = types.Keymap;


pub const init = Context.init;
pub const deinit = Context.deinit;


pub inline fn is_running() bool {
    return Context.get().running;
}


pub inline fn bar_status_fd() ?posix.fd_t {
    return Context.get().bar_status_fd;
}


pub inline fn handle_signal(sig: i32) void {
    Context.get().handle_signal(sig);
}


pub inline fn update_bar_status() void {
    Context.get().update_bar_status();
}
