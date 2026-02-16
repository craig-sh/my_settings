{ pkgs, ... }:
let
  setPersonalDisplay = pkgs.writeShellScriptBin "hypr-personal-display" ''
    ddcutil --display 1 setvcp 60 0x12
    ddcutil --display 2 setvcp 60 0x10
  '';
  setWorkDisplay = pkgs.writeShellScriptBin "hypr-work-display" ''
    ddcutil --display 1 setvcp 60 0x10
    ddcutil --display 2 setvcp 60 0x12
  '';
in
{

  home = {
    packages = with pkgs; [
      playerctl
      grimblast
      hyprpaper

      hyprpolkitagent
      wayvnc
      wl-clipboard
      cliphist
      setWorkDisplay
      setPersonalDisplay
      jq
      rose-pine-hyprcursor
      wl-clip-persist
    ];
    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.rose-pine-hyprcursor;
      name = "BreezeX-RosePine-Linux";
      size = 16;
    };
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-hyprcursor;
    };

    iconTheme = {
      name = "Pop-Icon-Theme";
      package = pkgs.pop-icon-theme;
    };

    theme = {
      name = "palenight";
      package = pkgs.palenight-theme;
    };

    # Note the different syntax for gtk3 and gtk4
    gtk3.extraConfig = {
      "gtk-cursor-theme-name" = "BreezeX-RosePine-Linux";
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-cursor-theme-name=BreezeX-RosePine-Linux
      '';
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    plugins = [
      # pkgs.hyprlandPlugins.hyprfocus
    ];
    settings = {
      "$mainMod" = "SUPER";

      ###################
      ### MY PROGRAMS ###
      ###################

      # See https://wiki.hypr.land/Configuring/Keywords/

      # Set programs that you use
      "$terminal" = "kitty";
      "$menu" = "rofi -show drun";

      #################
      ### AUTOSTART ###
      #################

      # Autostart necessary processes (like notifications daemons, status bars, etc.)
      # Or execute your favorite apps at launch like this:
      exec-once = [
        "kitty"
        "waybar"
        "systemctl --user start hyprpolkitagent"
        "hyprctl setcursor rose-pine-hyprcursor 16"
        "wl-paste --watch cliphist store"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "wl-clip-persist --clipboard regular"
      ];
      windowrule = [
        # Gaming rules on workpsace 8
        "workspace 8, match:class ^(steam)$"
        "float on, match:workspace 8"
        ################
        ##Special workspace tags###
        "tag +music, match:workspace special:music"
        "float on, match:workspace special:music"
        "tag +org, match:workspace speical:org"
        "float on, match:workspace special:org"
        #######
      ];

      workspace = [
        "special:music, on-created-empty: [float; size 80% 80%] spotify"
        "special:org, on-created-empty:[float; size 80% 80%] kitty --hold -d ~/Documents/org vim todo.org"
        "f[1], gapsout:0, gapsin:0, bordersize:0" # disable gaps when maximixed
      ];

      bind = [

        ###################
        # mod + shift
        #################
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, l, movewindow, r"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, j, movewindow, d"
        "$mainMod SHIFT, backslash, movewindow, mon:+1"
        # TODO n -> change layouts
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"

        ###################
        # mod + alt
        #################
        # Modify window
        "$mainMod ALT, S, togglefloating,"
        "$mainMod ALT, P, pseudo, " # dwindle
        "$mainMod ALT, C, togglesplit," # dwindle
        "$mainMod ALT, F, fullscreen,0"
        "$mainMod ALT, M, fullscreen,1"
        "$mainMod ALT, W, killactive,"
        #"$mainMod ALT, O, exec, hyprctl setprop active opaque toggle

        ###################
        # mod
        #################
        "$mainMod, Return, exec, $terminal"
        "$mainMod, Space, exec, $menu"
        "$mainMod, S, exec, grimblast copy area" # screenshot
        # Move focus with mainMod + vim keys
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"
        "$mainMod, c, movefocus, l" # Using this instead of cyclenext because of movefocus_cycles_fullscreen behavior
        "$mainMod, y, exec, dunstctl history-pop"
        "$mainMod, t, exec, dunstctl close"
        "$mainMod, n, exec, dunstctl close-all"
        "$mainMod, v, exec, rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons"

        "$mainMod, backslash, focusmonitor, +1"
        "$mainMod, bracketleft, workspace, m-1"
        "$mainMod, bracketright, workspace, m+1"
        "$mainMod, Tab, workspace, previous_per_monitor"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Music scratchpad
        "$mainMod, m, togglespecialworkspace, music"

        # org scratchpad
        "$mainMod, o, togglespecialworkspace, org"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        ###################
        # mod + control -- Heavy functions TODO move heavy ones from mod + alt here
        #################
        "$mainMod CTRL, q, exit"
        "$mainMod CTRL, r, exec, hyprctl reload"
        "$mainMod CTRL, w, exec, hypr-work-display"
        "$mainMod CTRL, p, exec, hypr-personal-display"
        "$mainMod CTRL, l, exec, hyprlock"
      ];
      binde = [
        ###################
        # mod + alt
        #################
        "$mainMod ALT, L, resizeactive, 10 0"
        "$mainMod ALT, H, resizeactive, -10 0"
        "$mainMod ALT, K, resizeactive, 0 -10"
        "$mainMod ALT, J, resizeactive, 0 10"
      ];

      bindl = [
        # Requires playerctl
        ", XF86AudioNext, exec, playerctl -p spotify next"
        ", XF86AudioPause, exec, playerctl -p spotify play-pause"
        ", XF86AudioPlay, exec, playerctl -p spotify play-pause"
        ", XF86AudioPrev, exec, playerctl -p spotify previous"
      ];

      bindel = [
        # Laptop multimedia keys for volume and LCD brightness
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
    extraConfig = ''
      debug:disable_logs = false
      #############################
      ### ENVIRONMENT VARIABLES ###
      #############################

      # See https://wiki.hypr.land/Configuring/Environment-variables/

      env = XCURSOR_SIZE,16
      env = HYPRCURSOR_SIZE,16
      env = HYPRCURSOR_THEME,rose-pine-hyprcursor

      #####################
      ### LOOK AND FEEL ###
      #####################

      # Refer to https://wiki.hypr.land/Configuring/Variables/

      # https://wiki.hypr.land/Configuring/Variables/#general
      general {
          gaps_in = 5
          gaps_out = 7

          border_size = 4

          # https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors
          #col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.active_border = rgba(93C572EE)
          col.inactive_border = rgba(595959aa)

          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          resize_on_border = false

          # Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
          allow_tearing = false

          layout = dwindle
      }

      # https://wiki.hypr.land/Configuring/Variables/#decoration
      decoration {
          rounding = 2
          rounding_power = 2

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0
          inactive_opacity = 1.0

          shadow {
              enabled = true
              range = 4
              render_power = 3
              color = rgba(1a1a1aee)
          }

          # https://wiki.hypr.land/Configuring/Variables/#blur
          blur {
              enabled = true
              size = 3
              passes = 1

              vibrancy = 0.1696
          }
      }

      # https://wiki.hypr.land/Configuring/Variables/#animations
      animations {
          enabled = yes, please :)

          # Default curves, see https://wiki.hypr.land/Configuring/Animations/#curves
          #        NAME,           X0,   Y0,   X1,   Y1
          bezier = easeOutQuint,   0.23, 1,    0.32, 1
          bezier = easeInOutCubic, 0.65, 0.05, 0.36, 1
          bezier = linear,         0,    0,    1,    1
          bezier = almostLinear,   0.5,  0.5,  0.75, 1
          bezier = quick,          0.15, 0,    0.1,  1

          # Default animations, see https://wiki.hypr.land/Configuring/Animations/
          #           NAME,          ONOFF, SPEED, CURVE,        [STYLE]
          animation = global,        1,     10,    default
          animation = border,        1,     5.39,  easeOutQuint
          animation = windows,       1,     4.79,  easeOutQuint
          animation = windowsIn,     1,     4.1,   easeOutQuint, popin 87%
          animation = windowsOut,    1,     1.49,  linear,       popin 87%
          animation = fadeIn,        1,     1.73,  almostLinear
          animation = fadeOut,       1,     1.46,  almostLinear
          animation = fade,          1,     3.03,  quick
          animation = layers,        1,     3.81,  easeOutQuint
          animation = layersIn,      1,     4,     easeOutQuint, fade
          animation = layersOut,     1,     1.5,   linear,       fade
          animation = fadeLayersIn,  1,     1.79,  almostLinear
          animation = fadeLayersOut, 1,     1.39,  almostLinear
          animation = workspaces,    1,     1.94,  almostLinear, fade
          animation = workspacesIn,  1,     1.21,  almostLinear, fade
          animation = workspacesOut, 1,     1.94,  almostLinear, fade
          animation = zoomFactor,    1,     7,     quick
      }

      # See https://wiki.hypr.land/Configuring/Dwindle-Layout/ for more
      dwindle {
          pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true # You probably want this
      }

      # See https://wiki.hypr.land/Configuring/Master-Layout/ for more
      master {
          new_status = master
      }

      ## https://wiki.hypr.land/Configuring/Variables/#misc
      misc {
          on_focus_under_fullscreen = 2
          force_default_wallpaper = 1 # Set to 0 or 1 to disable the anime mascot wallpapers
          disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
      }

      binds {
          movefocus_cycles_fullscreen = true
      }


      #############
      ### INPUT ###
      #############

      # https://wiki.hypr.land/Configuring/Variables/#input
      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =

          follow_mouse = 1

          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

          touchpad {
              natural_scroll = false
          }
      }

      # See https://wiki.hypr.land/Configuring/Gestures
      gesture = 3, horizontal, workspace

      ##############################
      ### WINDOWS AND WORKSPACES ###
      ##############################

      # See https://wiki.hypr.land/Configuring/Window-Rules/ for more
      # See https://wiki.hypr.land/Configuring/Workspace-Rules/ for workspace rules

      # Named window rules here for now. Unsure of how to do this in the home manager setting portion
      windowrule {
          # Fix some dragging issues with XWayland
          name = fix-xwayland-drags
          match:class = ^$
          match:title = ^$
          match:xwayland = true
          match:float = true
          match:fullscreen = false
          match:pin = false

          no_focus = true
      }

      # Hyprland-run windowrule
      windowrule {
          name = move-hyprland-run

          match:class = hyprland-run

          move = 20 monitor_h-120
          float = yes
      }

    '';
  };
}
