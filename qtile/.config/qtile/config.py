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

from libqtile.log_utils import logger # noqa
import os
import subprocess
from typing import List  # noqa: F401
from typing import Callable, NamedTuple

from libqtile import bar, hook, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.core.manager import Qtile
from libqtile.lazy import lazy
from libqtile.widget.volume import Volume

# HELPERS ###################
# Dracula color theme
THEME = {
    "background": "#282a36",
    "current": "#44475a",
    "selection": "#44475a",
    "foreground": "#f8f8f2",
    "comment": "#6272a4",
    "cyan": "#8be9fd",
    "green": "#50fa7b",
    "orange": "#ffb86c",
    "pink": "#ff79c6",
    "purple": "#bd93f9",
    "red": "#ff5555",
    "yellow": "#f1fa8c"
}

# TODO ctrl + tab breaks across screens
# TODO create GH issue for cmd_to_layout_index. type hint for index should be int not str. See usage in /usr/lib/python3.10/site-packages/libqtile/group.py:125


class MyLayout(NamedTuple):
    obj: layout.base.Layout
    index: int # noqa


_border_colors = {
    "border_focus": THEME["green"],           # "#859900",   # green
    "border_normal": THEME["background"],     # "#504339",   # grey
    "border_width": 6,
    "margin": 8
}


MONAD_TALL_LAYOUT = MyLayout(layout.MonadTall(**_border_colors), 0)
MAX_LAYOUT = MyLayout(layout.Max(), 1)
TREE_TAB_LAYOUT = MyLayout(layout.TreeTab(), 2)

LEFT_SCREEN_IDX = 1
RIGHT_SCREEN_IDX = 0


def move_to_next_screen(qtile, direction=1):
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
                qtile.cmd_next_screen()
            else:
                qtile.cmd_prev_screen()
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
        if cur_layout == MAX_LAYOUT.index:
            qtile.cmd_to_layout_index(MONAD_TALL_LAYOUT.index)
        else:
            qtile.cmd_to_layout_index(MAX_LAYOUT.index)
    return _inner


# Audio Volume/still needs work | replacing widget.Volume
class MyVolume(Volume):
    def _update_drawer(self):
        if self.volume <= 0:
            self.volume = '0%'
            self.text = '🔇' + str(self.volume)
        elif self.volume < 30:
            self.text = '🔈' + str(self.volume) + '%'
        elif self.volume < 80:
            self.text = '🔉' + str(self.volume) + '%'
        else:  # self.volume >=80:
            self.text = '🔊' + str(self.volume) + '%'

    def restore(self):
        self.timer_setup()

###################################


mod = "mod4"
terminal = "kitty"

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html

    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
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
    Key([mod, "shift"], "t", lazy.to_layout_index(TREE_TAB_LAYOUT.index), desc="Toggle between layouts"),

    # Groups
    Key(["control"], "Tab", lazy.screen.toggle_group()),
    Key([mod], "bracketright", lazy.function(go_next_group(1))),
    Key([mod], "bracketleft", lazy.function(go_next_group(-1))),

    # Screen
    Key([mod], "backslash", lazy.next_screen(), desc="Move to next scren"),
    Key([mod, "mod1"], "backslash", lazy.spawn("xrandr --output  DP-0 --auto --output HDMI-0 --auto --right-of DP-0"), desc="Refresh screens"),


    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),

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

    # Brightness
    Key([], "XF86MonBrightnessUp", lazy.spawn("xbacklight -inc 5"), desc="Increate Brightness"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("xbacklight -dec 5"), desc="Lower Brightness"),

    # Power
    Key([], "XF86Sleep", lazy.spawn("sudo systemctl suspend"), desc="Suspend Computer"),


    # Launchers
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], "space", lazy.spawn("rofi -show run"), desc="Spawn a command using a prompt widget"),

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
    TREE_TAB_LAYOUT.obj,
]

widget_defaults = dict(
    font='sans',
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()


volume = MyVolume(
    foreground=THEME["background"],
    background=THEME["purple"],
)


screens = [
    Screen(),
    Screen(
        top=bar.Bar(
            [
                widget.CurrentLayout(),
                widget.GroupBox(),
                widget.Prompt(),
                widget.WindowName(for_current_screen=True),
                widget.Chord(
                    chords_colors={
                        'launch': ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                volume,
                widget.Systray(),
                widget.Clock(format='%Y-%m-%d %a %I:%M %p'),
                widget.QuickExit(),
            ],
            24,
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
    ),
]

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
follow_mouse_focus = False
bring_front_click = False
cursor_warp = False
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

# Hooks

# subscribe for change of screen setup, just restart if called


@hook.subscribe.screen_change
def restart_on_randr(qtile, ev):
    # TODO only if numbers of screens changed
    qtile.cmd_restart()

# Hooks
# Runs startup applications


@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.call([home])
