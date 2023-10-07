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
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.core.manager import Qtile
from libqtile.lazy import lazy
from libqtile.log_utils import logger  # noqa
from libqtile.widget.volume import Volume

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

theme = SimpleNamespace(
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


class MyLayout(NamedTuple):
    obj: layout.base.Layout
    idx: int  # noqa


_border_colors = {
    "border_focus": theme.selected,
    "border_normal": theme.bar_bg,
    "border_width": 6,
    "margin": 8
}


def get_num_screens() -> int:
    """
    ➜ xrandr --listmonitors|head -1
    Monitors: 2
    """
    output = subprocess.run(["xrandr --listmonitors|head -1"], shell=True, capture_output=True).stdout.decode("utf-8")
    return int(output.split(":")[1].strip())


def is_laptop() -> bool:
    return os.path.isdir("/proc/acpi/button/lid")


MONAD_TALL_LAYOUT = MyLayout(layout.MonadTall(**_border_colors), 0)
MAX_LAYOUT = MyLayout(layout.Max(), 1)
TREE_TAB_LAYOUT = MyLayout(layout.TreeTab(), 2)
COL_LAYOUT = MyLayout(layout.Columns(**_border_colors), 3)

NUM_SCREENS = get_num_screens()
IS_LAPTOP = is_laptop()

LEFT_SCREEN_IDX = 1
RIGHT_SCREEN_IDX = 0

PREV_TOGGLE_LAYOUTS: Dict[int, int] = {}


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
            qtile.groups_map[name].cmd_toscreen()
            return

        if name in '12345':
            qtile.focus_screen(LEFT_SCREEN_IDX)
            qtile.groups_map[name].cmd_toscreen()
        else:
            qtile.focus_screen(RIGHT_SCREEN_IDX)
            qtile.groups_map[name].cmd_toscreen()

    return _inner


# TODO Make this function more generic (12345 is hardcoded)
# 1 moves right, -1 moves left
def go_next_group(direction: int) -> Callable:
    def _inner(qtile: Qtile) -> None:
        if direction not in [1, -1]:
            raise RuntimeError
        if len(qtile.screens) == 1:
            if direction == 1:
                qtile.current_screen.cmd_next_group()
            else:
                qtile.current_screen.cmd_prev_group()
            return

        # TODO map screen to nums
        cur_group = qtile.current_group.name
        if qtile.current_screen.index == LEFT_SCREEN_IDX:
            if direction == 1 and cur_group == "5":
                next_group = "1"
            elif direction == -1 and cur_group == "1":
                next_group = "5"
            elif cur_group in "67890":
                raise RuntimeError(f"EXPECTED SCREEN {LEFT_SCREEN_IDX}.CUR SCREEN {qtile.current_screen.index}. GROUP {cur_group}")
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
                raise RuntimeError(f"EXPECTED SCREEN {RIGHT_SCREEN_IDX}.CUR SCREEN {qtile.current_screen.index}. GROUP {cur_group}")
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
            qtile.cmd_to_layout_index(prev_layout)
        else:
            PREV_TOGGLE_LAYOUTS[qtile.current_screen.index] = cur_layout
            qtile.cmd_to_layout_index(MAX_LAYOUT.idx)
    return _inner


def focus_left() -> Callable:
    def _inner(qtile: Qtile) -> None:
        """Call focus_left but jump screens if necessary """
        if len(qtile.screens) == 1 or qtile.current_screen.index == LEFT_SCREEN_IDX:
            qtile.current_layout.cmd_left()
            return

        cur_layout = qtile.current_group.current_layout
        if cur_layout == MAX_LAYOUT.idx:
            qtile.cmd_next_screen()
        else:
            cur_window = qtile.current_window
            qtile.current_layout.cmd_left()
            if cur_window == qtile.current_window:
                qtile.cmd_next_screen()
    return _inner


def focus_right() -> Callable:
    def _inner(qtile: Qtile) -> None:
        """Call focus_right but jump screens if necessary """
        if len(qtile.screens) == 1 or qtile.current_screen.index == RIGHT_SCREEN_IDX:
            qtile.current_layout.cmd_right()
            return

        cur_layout = qtile.current_group.current_layout
        if cur_layout == MAX_LAYOUT.idx:
            qtile.cmd_next_screen()
        else:
            cur_window = qtile.current_window
            qtile.current_layout.cmd_right()
            if cur_window == qtile.current_window:
                qtile.cmd_next_screen()
    return _inner


# Audio Volume/still needs work | replacing widget.Volume
class MyVolume(Volume):
    def _update_drawer(self):
        if self.volume <= 0:
            self.volume = '0%'
            self.text = '婢 ' + str(self.volume)
        elif self.volume < 30:
            self.text = '奔 ' + str(self.volume) + '%'
        elif self.volume < 80:
            self.text = '墳 ' + str(self.volume) + '%'
        else:  # self.volume >=80:
            self.text = ' ' + str(self.volume) + '%'

    def restore(self):
        self.timer_setup()

###################################


mod = "mod4"
terminal = "kitty"

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html

    # Switch between windows
    Key([mod], "h", lazy.function(focus_left()), desc="Move focus to left"),
    Key([mod], "l", lazy.function(focus_right()), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "c", lazy.layout.next(),
        desc="Move window focus to other window"),

    # Change windows
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "s", lazy.window.toggle_floating(), desc='Toggle floating'),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc='Toggle fullscreen'),
    Key([mod, "shift"], "backslash", lazy.function(move_to_next_screen)),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(),
        desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(),
        desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    # mod1 == alt
    Key([mod, "mod1"], "h", lazy.layout.grow_left(),
        desc="Grow window to the left"),
    Key([mod, "mod1"], "l", lazy.layout.grow_right(),
        desc="Grow window to the right"),
    Key([mod, "mod1"], "j", lazy.layout.grow_down(),
        desc="Grow window down"),
    Key([mod, "mod1"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),

    # Changing Layouts
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "m", lazy.function(toggle_max_layout()), desc="Toggle max layout"),
    Key([mod], "t", lazy.to_layout_index(MONAD_TALL_LAYOUT.index), desc="Change to monadtall"),
    # Key([mod, "shift"], "t", lazy.to_layout_index(TREE_TAB_LAYOUT.index), desc="Toggle between layouts"),

    # Groups
    Key(["control"], "Tab", lazy.screen.toggle_group()),
    Key([mod], "bracketright", lazy.function(go_next_group(1))),
    Key([mod], "bracketleft", lazy.function(go_next_group(-1))),

    # Screen
    Key([mod], "backslash", lazy.next_screen(), desc="Move to next scren"),
    Key([mod, "mod1"], "backslash", lazy.spawn("xrandr --output  DP-0 --auto --output HDMI-0 --auto --right-of DP-0"), desc="Refresh screens"),


    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),

    # Brightness
    Key([], "XF86MonBrightnessUp", lazy.spawn("xbacklight -inc 5"), desc="Increate Brightness"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("xbacklight -dec 5"), desc="Lower Brightness"),

    # Power
    Key([], "XF86Sleep", lazy.spawn("sudo systemctl suspend"), desc="Suspend Computer"),

    # Launchers
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], "space", lazy.spawn("rofi -show run"), desc="Spawn a command using a prompt widget"),

]

if not is_laptop():
    # bug with how keys are captured on laptop with Xmodmap
    keys += [
        # Sound
        Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"), desc="Toggle Mute"),
        Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +2%"), desc="Raise Volume"),
        Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -2%"), desc="Lower Volume"),

        # Music
        Key([], "XF86AudioNext", lazy.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next"), desc="Next song"),
        Key([], "XF86AudioNext", lazy.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next"), desc="Next song"),
        Key([], "XF86AudioPrev", lazy.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous"), desc="Previous song"),
        Key([], "XF86AudioStop", lazy.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop"), desc="Stop music"),
        Key([], "XF86AudioPlay", lazy.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"), desc="Play/Pause music"),
    ]


groups = [Group(i) for i in "1234567890"]
for i in groups:
    keys.append(Key([mod], i.name, lazy.function(go_to_group(i.name))))
    keys.append(Key([mod, "shift"], i.name, lazy.window.togroup(i.name), desc="move focused window to group {}".format(i.name)))

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
    background=theme.bar_bg,
    foreground=theme.bar_fg,
    active=theme.bar_active,
    max_title_width=300,
)
extension_defaults = widget_defaults.copy()

sep_args = dict(
    foreground=theme.sep_fg,
    linewidth=0,
)


def make_sep_icon(background=theme.sep_bg, foreground=theme.sep_fg):
    return widget.TextBox(
        text="/",
        fontsize="33",
        padding=2,
        background=background,
        foreground=foreground,
    )


def make_icon(icon, background=theme.sep_bg, foreground=theme.sep_fg):
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
        block_highlight_text_color=theme.selected,
        visible_groups=visible_groups,
    ),
    # widget.Sep(**sep_args),  # make_sep_icon(background=theme.color4),
    widget.CurrentLayout(foreground=theme.color10),
    widget.Sep(**sep_args),  # make_sep_icon(),
    widget.Prompt(),
    widget.TaskList(),
    widget.Chord(
        chords_colors={
            'launch': ("#ff0000", "#ffffff"),
        },
        name_transform=lambda name: name.upper(),
    ),
    widget.Sep(**sep_args),  # make_sep_icon(),
    #make_icon(" ", background=theme.color15, foreground=theme.inactive_tab_foreground),
    widget.DF(visible_on_warn=True, background=theme.color15, foreground=theme.inactive_tab_foreground),
    #widget.Sep(**sep_args, background=theme.color10),  # make_sep_icon(),
    widget.CheckUpdates(
        colour_have_updates=theme.color1,
        colour_no_updates=theme.bar_fg_inactive,
        display_format=" {updates}",
        fontsize=25,
        background=theme.color6,
        no_updates_string=" ",
        distro="Arch_checkupdates",
    ),
]
if IS_LAPTOP:
    widget_list += [
        widget.Battery(background=theme.cursor, foreground=theme.color0, format='{char} {percent:2.0%} {hour:d}:{min:02d}', charge_char='', discharge_char='', full_char=''),
        make_icon("", background=theme.color11, foreground=theme.inactive_tab_foreground),
        widget.Backlight(background=theme.color11, foreground=theme.color0, brightness_file='/sys/class/backlight/intel_backlight/brightness', max_brightness_file='/sys/class/backlight/intel_backlight/max_brightness'),
    ]

widget_list += [
    make_icon("", background=theme.color2, foreground=theme.inactive_tab_foreground),
    widget.Wlan(background=theme.color2, foreground=theme.color0),
    widget.Sep(**sep_args, background=theme.color2),  # make_sep_icon(),
    make_icon("", background=theme.color6, foreground=theme.inactive_tab_foreground),
    widget.Memory(format='{MemPercent}%', background=theme.color6, foreground=theme.inactive_tab_foreground),
    widget.Sep(**sep_args, background=theme.color6),  # make_sep_icon(),
    make_icon("﬙", background=theme.color16, foreground=theme.inactive_tab_foreground),
    widget.CPU(format='{freq_current}GHz {load_percent}%', background=theme.color16, foreground=theme.inactive_tab_foreground),
    widget.Sep(**sep_args, background=theme.color4),  # make_sep_icon(),
    MyVolume(fontsize="25", background=theme.color4, foreground=theme.color0),
    widget.Sep(**sep_args, background=theme.color5),  # make_sep_icon(),
    make_icon("", background=theme.color5, foreground=theme.inactive_tab_foreground),
    widget.Clock(format='%Y-%m-%d %H:%M', background=theme.color5, foreground=theme.color0),
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
        0,
        Screen(
            top=bar.Bar(
                [
                    widget.GroupBox(
                        block_highlight_text_color=theme.selected,
                        visible_groups="67890",
                    ),
                    widget.CurrentLayout(foreground=theme.color10),
                    widget.TaskList()
                ],
                40
            )
        ),
    )

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]


dgroups_key_binder = None
dgroups_app_rules = []  # type: List
follow_mouse_focus = True
bring_front_click = False
cursor_warp = True
floating_layout = layout.Floating(float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    *layout.Floating.default_float_rules,
    Match(wm_class='confirmreset'),  # gitk
    Match(wm_class='makebranch'),  # gitk
    Match(wm_class='maketag'),  # gitk
    Match(wm_class='ssh-askpass'),  # ssh-askpass
    Match(title='branchdialog'),  # gitk
    Match(title='pinentry'),  # GPG key password entry
])
auto_fullscreen = True
focus_on_window_activation = "focus"
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

@hook.subscribe.client_new
def handle_client_new(client):
    if "KeePassXC".lower() in client.name.lower():
        # Any keepass window should be moved to current screen
        # usually pop-ups
        client.cmd_toscreen()



@hook.subscribe.current_screen_change
def screen_change():
    if len(imported_qtile.screens) != 2:
        return

    # Highlight the layout block differently depending oun which screen is focused
    for screen in imported_qtile.screens:
        if screen == imported_qtile.current_screen:
            screen.top.widgets[1].background = theme.screen_active
        else:
            screen.top.widgets[1].background = theme.screen_inactive
        screen.top.draw()


@hook.subscribe.screen_change
def restart_on_randr(ev):
    # TODO only if numbers of screens changed
    num_screens_changed = NUM_SCREENS != get_num_screens()
    from datetime import datetime
    logger.error(f"SCREEN change called at {datetime.now()}: {num_screens_changed=}")
    if num_screens_changed:
        imported_qtile.cmd_restart()
        # imported_qtile.cmd_reload_config()
        # _preset_screens(imported_qtile)


@hook.subscribe.startup_complete
def on_start():
    _preset_screens(imported_qtile)
    from datetime import datetime
    num_screens_chaned = NUM_SCREENS != get_num_screens()
    logger.error(f"ON START  called at {datetime.now()}: {num_screens_chaned=}")


@hook.subscribe.startup_once
def start_once():
    # Runs startup applications
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.call([home])
