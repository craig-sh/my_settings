# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import subprocess
from time import sleep
from types import SimpleNamespace
from typing import List  # noqa: F401
from typing import Callable, Dict, NamedTuple

from libqtile import bar, hook, layout
from libqtile import qtile as imported_qtile
from libqtile import widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.core.manager import Qtile
from libqtile.lazy import lazy
from libqtile.log_utils import logger  # noqa
from libqtile.widget.volume import Volume

try:
    from libqtile.widget.pulse_volume import PulseVolume
except ModuleNotFoundError:
    # Until we migrate to pipewire + pulse completely this is ok
    DEFAULT_VOLUME_CLASS = Volume
else:
    DEFAULT_VOLUME_CLASS = PulseVolume

from datetime import datetime
import socket


class _MyLayout(NamedTuple):
    obj: layout.base.Layout
    idx: int  # noqa

class _HostSpecifics(NamedTuple):
    name: str
    left_screen_idx: int = 0
    right_screen_idx: int = 1
    add_media_keys: bool | None = None
    xrandr_cmd: str = "dunstify 'Not Denfied'"
    network_interface: str | None = None
    wireless: bool = False
    cputhermal: str | None = None
    volumeClass: type[Volume] =  DEFAULT_VOLUME_CLASS
    orgNotes: str = "~/Documents/org"


class _KeyMap(NamedTuple):
    mod: list[str]
    key: str
    action: Callable
    desc: str


def _validate_key_map_group(maps: list[_KeyMap]):
    assert len({tuple(m.mod) for m in maps}) <= 1, "Group has more than 1 modifier"
    assert len({m.key for m in maps}) == len(maps), "Duplicate key in key_map group"


# HELPERS ###################
# Onedark kitty theme - from https://github.com/ful1e5/dotfiles/blob/main/kitty/.config/kitty/themes/onedark.conf#L9
THEME = {
    "background": "#282c34",
    "foreground": "#abb2bf",
    "selection_background": "#393f4a",
    "selection_foreground": "#abb2bf",
    "url_color": "#98c379",
    "cursor": "#528bff",
    # Tabs
    "active_tab_background": "#61afef",
    "active_tab_foreground": "#282c34",
    "inactive_tab_background": "#abb2bf",
    "inactive_tab_foreground": "#282c34",
    # Windows Border
    "active_border_color": "#393f4a",
    "inactive_border_color": "#393f4a",
    # normal
    "color0": "#20232A",
    "color1": "#e86671",
    "color2": "#98c379",
    "color3": "#e5c07b",
    "color4": "#61afef",
    "color5": "#c678dd",
    "color6": "#56b6c2",
    "color7": "#798294",
    # bright
    "color8": "#5c6370",
    "color9": "#e86671",
    "color10": "#98c379",
    "color11": "#e5c07b",
    "color12": "#61afef",
    "color13": "#c678dd",
    "color14": "#56b6c2",
    "color15": "#abb2bf",
    # extended colors
    "color16": "#d19a66",
    "color17": "#f65866",
}

_theme = SimpleNamespace(
    screen_active=THEME["color0"],
    screen_inactive=THEME["color7"],
    bar_bg=THEME["background"],
    bar_fg=THEME["foreground"],
    bar_fg_inactive=THEME["inactive_border_color"],
    sep_fg=THEME["color2"],
    sep_bg=THEME["background"],
    bar_active=THEME["color3"],
    selected=THEME["color10"],
    **THEME,
)

# TODO ctrl + tab breaks across screens
# TODO create GH issue for cmd_to_layout_index. type hint for index should be int not str. See usage in /usr/lib/python3.10/site-packages/libqtile/group.py:125

_border_colors = {"border_focus": _theme.selected, "border_normal": _theme.bar_bg, "border_width": 6, "margin": 8}


def _get_num_screens() -> int:
    """
    ➜ xrandr --listmonitors|head -1
    Monitors: 2
    """
    output = subprocess.run(["xrandr --listmonitors|head -1"], shell=True, capture_output=True).stdout.decode("utf-8")
    return int(output.split(":")[1].strip())


def _is_laptop() -> bool:
    return os.path.isdir("/proc/acpi/button/lid")

HOSTNAME = socket.gethostname()
MONAD_TALL_LAYOUT = _MyLayout(layout.MonadTall(**_border_colors), 0)
MAX_LAYOUT = _MyLayout(layout.Max(), 1)
TREE_TAB_LAYOUT = _MyLayout(layout.TreeTab(), 2)
COL_LAYOUT = _MyLayout(layout.Columns(**_border_colors), 3)

NUM_SCREENS = _get_num_screens()
IS_LAPTOP = _is_laptop()

PREV_TOGGLE_LAYOUTS: Dict[int, int] = {}

# "xrandr --output  DP-0 --auto --output HDMI-0 --auto --right-of DP-0"
_host_specifics: dict[str, _HostSpecifics] = {
    "hypernix": _HostSpecifics(
        name="hypernix",
        left_screen_idx=0,
        right_screen_idx=1,
        add_media_keys=True,
        network_interface="wlp14s0f3u1",
        wireless=True,
        cputhermal="Tctl",
    ),
    "carbonarch": _HostSpecifics(name="carbonarch", add_media_keys=False, wireless=True, network_interface="wlan0", volumeClass=Volume),
}

_generic_host = _HostSpecifics(name="generic", add_media_keys=not IS_LAPTOP)

_host_config: _HostSpecifics = _host_specifics.get(HOSTNAME, _generic_host)


def move_to_next_screen(qtile, direction=1):
    if len(qtile.screens) == 1:
        return
    other_scr_index = (qtile.screens.index(qtile.current_screen) + direction) % len(qtile.screens)
    other_scr = qtile.screens[other_scr_index]
    othergroup = other_scr.group
    if othergroup:
        qtile.move_to_group(othergroup.name)
        qtile.focus_screen(other_scr_index)


# TODO Make this function more generic (12345 is hardcoded)
def go_to_group(name: str) -> Callable:
    def _inner(qtile: Qtile) -> None:
        if len(qtile.screens) == 1:
            qtile.groups_map[name].toscreen()
            return

        if name in '12345':
            qtile.focus_screen(_host_config.left_screen_idx)
            qtile.groups_map[name].toscreen()
        else:
            qtile.focus_screen(_host_config.right_screen_idx)
            qtile.groups_map[name].toscreen()

    return _inner


# TODO Make this function more generic (12345 is hardcoded)
# 1 moves right, -1 moves left
def go_next_group(direction: int) -> Callable:
    def _inner(qtile: Qtile) -> None:
        if direction not in [1, -1]:
            raise RuntimeError
        if len(qtile.screens) == 1:
            if direction == 1:
                qtile.current_screen.next_group()
            else:
                qtile.current_screen.prev_group()
            return

        # TODO map screen to nums
        cur_group = qtile.current_group.name
        if qtile.current_screen.index == _host_config.left_screen_idx:
            if direction == 1 and cur_group == "5":
                next_group = "1"
            elif direction == -1 and cur_group == "1":
                next_group = "5"
            elif cur_group in "67890":
                raise RuntimeError(f"EXPECTED SCREEN {_host_config.left_screen_idx}.CUR SCREEN {qtile.current_screen.index}. GROUP {cur_group}")
            else:
                next_group = str(int(cur_group) + direction)
        else:
            if direction == 1 and cur_group == "0":
                next_group = "6"
            elif direction == 1 and cur_group == "9":
                next_group = "0"
            elif direction == -1 and cur_group == "0":
                next_group = "9"
            elif direction == -1 and cur_group == "6":
                next_group = "0"
            elif cur_group in "12345":
                raise RuntimeError(f"EXPECTED SCREEN {_host_config.right_screen_idx}.CUR SCREEN {qtile.current_screen.index}. GROUP {cur_group}")
            else:
                next_group = str(int(cur_group) + direction)
        qtile.current_screen.set_group(qtile.groups_map[next_group])
    return _inner


def toggle_max_layout() -> Callable:
    def _inner(qtile: Qtile) -> None:
        """Toggle between max layout and monadtall"""
        cur_layout = qtile.current_group.current_layout
        prev_layout = PREV_TOGGLE_LAYOUTS.get(qtile.current_screen.index, MONAD_TALL_LAYOUT.idx)
        if cur_layout == MAX_LAYOUT.idx:
            qtile.to_layout_index(prev_layout)
        else:
            PREV_TOGGLE_LAYOUTS[qtile.current_screen.index] = cur_layout
            qtile.to_layout_index(MAX_LAYOUT.idx)
    return _inner


def focus_left() -> Callable:
    def _inner(qtile: Qtile) -> None:
        """Call focus_left but jump screens if necessary """
        if len(qtile.screens) == 1 or qtile.current_screen.index == _host_config.left_screen_idx:
            qtile.current_layout.left()
            return

        cur_layout = qtile.current_group.current_layout
        if cur_layout == MAX_LAYOUT.idx:
            qtile.next_screen()
        else:
            cur_window = qtile.current_window
            qtile.current_layout.left()
            if cur_window == qtile.current_window:
                qtile.next_screen()
    return _inner


def focus_right() -> Callable:
    def _inner(qtile: Qtile) -> None:
        """Call focus_right but jump screens if necessary """
        if len(qtile.screens) == 1 or qtile.current_screen.index == _host_config.right_screen_idx:
            qtile.current_layout.right()
            return

        cur_layout = qtile.current_group.current_layout
        if cur_layout == MAX_LAYOUT.idx:
            qtile.next_screen()
        else:
            cur_window = qtile.current_window
            qtile.current_layout.right()
            if cur_window == qtile.current_window:
                qtile.next_screen()
    return _inner

@lazy.function
def switch_monitors(qtile, setup):
    if setup == "work":
        display1 = "0x10"
        display2 = "0x11"
    elif setup == "personal":
        display1 = "0x11"
        display2 = "0x10"

    # Tried Popen to parallelize but its flaky..didn't bother debugging why
    subprocess.run(f"ddcutil --display 1 setvcp 60 {display1}", shell=True)
    subprocess.run(f"ddcutil --display 2 setvcp 60 {display2}", shell=True)


# Audio Volume/still needs work | replacing widget.Volume
class MyVolume(_host_config.volumeClass):
    def _update_drawer(self):
        if self.volume <= 0:
            self.volume = "0%"
            self.text = "󰖁 " + str(self.volume)
        elif self.volume < 15:
            self.text = "󰕿 " + str(self.volume) + "%"
        elif self.volume < 50:
            self.text = "󰖀" + str(self.volume) + "%"
        elif self.volume < 80:
            self.text = "󰕾" + str(self.volume) + "%"
        else:  # self.volume >=80:
            self.text = "" + str(self.volume) + "%"

    def restore(self):
        self.timer_setup()


### GROUPS
groups = [Group(i) for i in "1234567890"]

# Add in scratchpad groups
groups.append(
    ScratchPad(
        "scratchpad", [
            DropDown(
                "org",
                ["kitty", "--hold", "-d", _host_config.orgNotes, "vim", "todo.org"],
                on_focus_lost_hide=True,
                warp_pointer=True,
                height=0.8,
            ),
            DropDown(
                "keepassxc",
                ["keepassxc"],
                on_focus_lost_hide=True,
                warp_pointer=True,
                height=0.8,
            ),
            DropDown(
                "spotify",
                ["spotify"],
                on_focus_lost_hide=True,
                warp_pointer=True,
                height=0.8,
                match=Match(wm_class="spotify"),
            ),
        ]
    )
)
#####


###################################


mod = "mod4"
terminal = "kitty"
_shift = "shift"
_alt = "mod1"
_control = "control"


###################
# mod + shift
#################
_mod_shift_keys = [
    ("h", lazy.layout.shuffle_left(), "Move window to the left"),
    ("l", lazy.layout.shuffle_right(), "Move window to the right"),
    ("j", lazy.layout.shuffle_down(), "Move window down"),
    ("k", lazy.layout.shuffle_up(), "Move window up"),
    ("Return", lazy.layout.toggle_split(), "Toggle between split and unsplit sides of stack"),
    ("backslash", lazy.function(move_to_next_screen), "Move window up"),
    ("n", lazy.next_layout(), "Toggle between layouts"),
]
_mod_shift_keys += [
    (i.name, lazy.window.togroup(i.name), f"Move window to group {i.name}")
    for i in groups if not isinstance(i, ScratchPad)
]
_mod_shift = [_KeyMap([mod, _shift], *k) for k in _mod_shift_keys]

###################
# mod + alt
#################
_mod_alt_keys = [
    # Change windows
    ("s", lazy.window.toggle_floating(), "Toggle floating"),
    ("f", lazy.window.toggle_fullscreen(), "Toggle fullscreen"),
    ("m", lazy.function(toggle_max_layout()), "Toggle max layout"),
    ("w", lazy.window.kill(), "Kill focused window"),
    ("h", lazy.layout.grow_left(), "Grow window to the left"),
    ("l", lazy.layout.grow_right(), "Grow window to the right"),
    ("j", lazy.layout.grow_down(), "Grow window down"),
    ("k", lazy.layout.grow_up(), "Grow window up"),
    ("n", lazy.layout.normalize(), "Reset all window sizes"),
    ("backslash", lazy.spawn(_host_config.xrandr_cmd), "Refresh screens"),
]
_mod_alt = [_KeyMap([mod, _alt], *k) for k in _mod_alt_keys]

###################
# mod + control -- Heavy functions TODO move heavy ones from mod + alt here
#################
_mod_control_keys = [
    ("r", lazy.reload_config(), "Reload the config"),
    ("q", lazy.shutdown(), "Shutdown Qtile"),
    ("w", switch_monitors(setup="work"), "Switch monitor to work inputs"),
    ("p", switch_monitors(setup="personal"), "Switch monitor to personal inputs"),
]
_mod_control = [_KeyMap([mod, _control], *k) for k in _mod_control_keys]

###################
# mod
#################
_mod_keys = [
    # Program launch
    ("space", lazy.spawn("rofi -show run"), "Spawn a command using a prompt widget"),
    ("Return", lazy.spawn(terminal), "Launch terminal"),
    # Switch between windows
    ("h", lazy.function(focus_left()), "Move focus to left"),
    ("l", lazy.function(focus_right()), "Move focus to right"),
    ("j", lazy.layout.down(), "Move focus down"),
    ("k", lazy.layout.up(), "Move focus up"),
    ("c", lazy.layout.next(), "Move window focus to other window"),
    ("backslash", lazy.next_screen(), "Move to next scren"),
    # Groups
    ("bracketright", lazy.function(go_next_group(1)), "Focus next group"),
    ("bracketleft", lazy.function(go_next_group(-1)), "Focus prev group"),
    ("Tab", lazy.screen.toggle_group(), "Switch to last used group on the current screen"),
    # Notifications
    ("y", lazy.spawn("dunstctl history-pop"), "show last notification"),
    ("t", lazy.spawn("dunstctl close"), "close most recent notifications"),
    ("n", lazy.spawn("dunstctl close-all"), "close all notifications"),
    ("o", lazy.group['scratchpad'].dropdown_toggle("org"), "activate org dropdown"),
    ("p", lazy.group['scratchpad'].dropdown_toggle("keepassxc"), "activate keepassxc dropdown"),
    ("m", lazy.group['scratchpad'].dropdown_toggle("spotify"), "activate spotify dropdown"),
]
_mod_keys += [(i.name, lazy.function(go_to_group(i.name)), f"Go to group {i.name}") for i in groups if not isinstance(i, ScratchPad)]

_mod_only = [_KeyMap([mod], *k) for k in _mod_keys]

_mod_none_keys = [
    # Brightness
    ("XF86MonBrightnessUp", lazy.spawn("xbacklight -inc 5"), "Increate Brightness"),
    ("XF86MonBrightnessDown", lazy.spawn("xbacklight -dec 5"), "Lower Brightness"),
    # Power
    ("XF86Sleep", lazy.spawn("sudo systemctl suspend"), "Suspend Computer"),
]

if _host_config.add_media_keys:
    # bug with how keys are captured on laptop with Xmodmap
    _mod_none_keys += [
        # Sound
        ("XF86AudioMute", lazy.spawn("wpctl set-sink-mute @DEFAULT_SINK@ toggle"), "Toggle Mute"),
        ("XF86AudioRaiseVolume", lazy.spawn("wpctl set-volume @DEFAULT_SINK@ 2%+"), "Raise Volume"),
        ("XF86AudioLowerVolume", lazy.spawn("wpctl set-volume @DEFAULT_SINK@ 2%-"), "Lower Volume"),
        # Music
        ("XF86AudioNext", lazy.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next"), "Next song"),
        ("XF86AudioPrev", lazy.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous"), "Previous song"),
        ("XF86AudioStop", lazy.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop"), "Stop music"),
        ("XF86AudioPlay", lazy.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"), "Play/Pause music"),
    ]

_mod_none = [_KeyMap([], *k) for k in _mod_none_keys]

_all_keys: list[list[_KeyMap]] = [_mod_shift, _mod_alt, _mod_control, _mod_only,_mod_none]

keys = []
for kmap_group in _all_keys:
    _validate_key_map_group(kmap_group)
    keys += [Key(k.mod, k.key, k.action, desc=k.desc) for k in kmap_group]

# layouts = [
#    layout.Columns(border_focus_stack=['#d75f5f', '#8f3d3d'], border_width=4),
#    layout.Max(),
#    # Try more layouts by unleashing below layouts.
#    #layout.Stack(num_stacks=2),
#    #layout.Bsp(),
#    #layout.Matrix(),
#    layout.MonadTall(),
#    #layout.MonadWide(),
#    #layout.RatioTile(),
#    #layout.Tile(),
#    layout.TreeTab(),
#    #layout.VerticalTile(),
#    #layout.Zoomy(),
# ]



layouts = [
    MONAD_TALL_LAYOUT.obj,
    MAX_LAYOUT.obj,
    #    TREE_TAB_LAYOUT.obj,
    COL_LAYOUT.obj,
]

widget_defaults = dict(
    font="FantasqueSansM Nerd Font Mono",
    fontsize=20,
    padding=3,
    background=_theme.bar_bg,
    foreground=_theme.bar_fg,
    active=_theme.bar_active,
    max_title_width=300,
)
extension_defaults = widget_defaults.copy()

sep_args = dict(
    foreground=_theme.sep_fg,
    linewidth=0,
)


def make_sep_icon(background=_theme.sep_bg, foreground=_theme.sep_fg):
    return widget.TextBox(
        text="/",
        fontsize="33",
        padding=2,
        background=background,
        foreground=foreground,
    )


def make_icon(icon, background=_theme.sep_bg, foreground=_theme.sep_fg):
    return widget.TextBox(
        text=icon,
        fontsize="33",
        padding=0,
        background=background,
        foreground=foreground,
    )


visible_groups = "12345"
if NUM_SCREENS == 1:
    visible_groups = "1234567890"

widget_list = [
    widget.GroupBox(
        block_highlight_text_color=_theme.selected,
        visible_groups=visible_groups,
    ),
    # widget.Sep(**sep_args),  # make_sep_icon(background=theme.color4),
    widget.CurrentLayout(foreground=_theme.color10),
    widget.Sep(**sep_args),  # make_sep_icon(),
    widget.Prompt(),
    widget.TaskList(),
    widget.Chord(
        chords_colors={
            "launch": ("#ff0000", "#ffffff"),
        },
        name_transform=lambda name: name.upper(),
    ),
    widget.Sep(**sep_args),  # make_sep_icon(),
    # make_icon(" ", background=theme.color15, foreground=theme.inactive_tab_foreground),
    widget.DF(visible_on_warn=True, background=_theme.color15, foreground=_theme.inactive_tab_foreground),
    # widget.Sep(**sep_args, background=theme.color10),  # make_sep_icon(),
    widget.CheckUpdates(
        colour_have_updates=_theme.color1,
        colour_no_updates=_theme.bar_fg_inactive,
        display_format=" {updates}",
        fontsize=25,
        background=_theme.color6,
        no_updates_string=" ",
        distro="Arch_checkupdates",
    ),
]
if IS_LAPTOP:
    widget_list += [
        widget.Battery(background=_theme.cursor, foreground=_theme.color0, format="{char} {percent:2.0%} {hour:d}:{min:02d}", charge_char="", discharge_char="", full_char=""),
        make_icon("", background=_theme.color11, foreground=_theme.inactive_tab_foreground),
        widget.Backlight(
            background=_theme.color11,
            foreground=_theme.color0,
            brightness_file="/sys/class/backlight/intel_backlight/brightness",
            max_brightness_file="/sys/class/backlight/intel_backlight/max_brightness",
        ),
    ]

if _host_config.wireless:
    widget_list += [
        make_icon("", background=_theme.color2, foreground=_theme.inactive_tab_foreground),
        widget.Wlan(background=_theme.color2, foreground=_theme.color0, interface=_host_config.network_interface),
        widget.Sep(**sep_args, background=_theme.color2),  # make_sep_icon(),
    ]

widget_list += [
    make_icon("", background=_theme.color6, foreground=_theme.inactive_tab_foreground),
    widget.Memory(format="{MemPercent}%", background=_theme.color6, foreground=_theme.inactive_tab_foreground),
    widget.Sep(**sep_args, background=_theme.color6),  # make_sep_icon(),
    make_icon("", background=_theme.color16, foreground=_theme.inactive_tab_foreground),
    widget.CPU(format="{freq_current}GHz {load_percent}%", background=_theme.color16, foreground=_theme.inactive_tab_foreground),
]
if _host_config.cputhermal:
    widget_list += [
        widget.ThermalSensor(background=_theme.color16, foreground=_theme.inactive_tab_foreground, threshold=80.0, tag_sensor=_host_config.cputhermal, format="{temp:.0f}{unit}"),
    ]

widget_list += [
    widget.Sep(**sep_args, background=_theme.color4),  # make_sep_icon(),
    MyVolume(fontsize="25", background=_theme.color4, foreground=_theme.color0),
    widget.Sep(**sep_args, background=_theme.color5),  # make_sep_icon(),
    make_icon("", background=_theme.color5, foreground=_theme.inactive_tab_foreground),
    widget.Clock(format="%Y-%m-%d %H:%M", background=_theme.color5, foreground=_theme.color0),
    widget.Sep(**sep_args),  # make_sep_icon(),
    widget.Systray(),
]


screens = [
    Screen(
        top=bar.Bar(
            widget_list,
            40,
        ),
    ),
]

if NUM_SCREENS > 1:
    screens.insert(
        _host_config.right_screen_idx,
        Screen(
            top=bar.Bar(
                [
                    widget.GroupBox(
                        block_highlight_text_color=_theme.selected,
                        visible_groups="67890",
                    ),
                    widget.CurrentLayout(foreground=_theme.color10),
                    widget.TaskList(),
                ],
                40,
            )
        ),
    )

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]


dgroups_key_binder = None
dgroups_app_rules = []  # type: List
follow_mouse_focus = True
bring_front_click = "floating_only"
floats_kept_above = True
cursor_warp = True
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"


def _preset_screens(qtile: Qtile):
    # preset the screens for switching next/prev of screens/groups behaves as expected
    TIME_OF_SLEEP = 0.1
    sleep(2 * TIME_OF_SLEEP)
    go_to_group("1")(qtile)
    sleep(TIME_OF_SLEEP)
    go_to_group("2")(qtile)
    sleep(TIME_OF_SLEEP)
    if len(qtile.screens) > 1:
        go_to_group("6")(qtile)
        sleep(TIME_OF_SLEEP)
        go_to_group("7")(qtile)
        sleep(TIME_OF_SLEEP)
        go_to_group("6")(qtile)
        sleep(TIME_OF_SLEEP)
    go_to_group("1")(qtile)


# Hooks


#@hook.subscribe.client_new
#def handle_client_new(client):
#    if "KeePassXC".lower() in client.name.lower():
#        pass
#        # Any keepass window should be moved to current screen
#        # usually pop-ups. Should also be dsplayed on top of everything
#        #client.toggle_floating()
#        #client.toscreen()
#        #client.bring_to_front()
#        #client.focus()
#        #client.toggle_floating()
#        #client.focus()


@hook.subscribe.current_screen_change
def screen_change():
    if len(imported_qtile.screens) != 2:
        return

    # Highlight the layout block differently depending oun which screen is focused
    for screen in imported_qtile.screens:
        if screen == imported_qtile.current_screen:
            screen.top.widgets[1].background = _theme.screen_active
        else:
            screen.top.widgets[1].background = _theme.screen_inactive
        screen.top.draw()


@hook.subscribe.screen_change
def restart_on_randr(ev):
    num_screens_changed = NUM_SCREENS != _get_num_screens()
    logger.info(f"SCREEN change called at {datetime.now()}: {num_screens_changed=}")
    if num_screens_changed:
        imported_qtile.restart()
        # imported_qtile.reload_config()
        # _preset_screens(imported_qtile)


@hook.subscribe.startup_complete
def on_start():
    _preset_screens(imported_qtile)
    num_screens_changed = NUM_SCREENS != _get_num_screens()
    logger.info(f"ON START  called at {datetime.now()}: {num_screens_changed=}")


@hook.subscribe.startup_once
def start_once():
    # Runs startup applications
    #go_to_group("0")(imported_qtile)
    #sleep(0.5)
    #subprocess.Popen("qtile run-cmd -g 0 keepassxc", shell=True)
    #subprocess.Popen("qtile run-cmd -g 5 spotify", shell=True)
    #subprocess.Popen("qtile run-cmd -g 6 firefox", shell=True)
    subprocess.Popen("qtile run-cmd -g 1 kitty", shell=True)
    subprocess.Popen("qtile run-cmd -g 7 kitty", shell=True)
    #go_to_group("6")(imported_qtile)
    # subprocess.call("bash /home/craig/.config/qtile/autostart.sh", shell=True)
