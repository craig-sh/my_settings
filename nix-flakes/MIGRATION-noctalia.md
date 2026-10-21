# Noctalia v5 migration (paused)

Replace the classic Hyprland desktop shell (waybar + dunst + rofi binds +
hyprlock + hypridle) with [Noctalia v5](https://docs.noctalia.dev/noctalia/)
on **hypernix** and **carbonnix**, keeping the classic setup switchable via
commented import lines.

- Branch: `notalia`
- Status: **built and dix-checked, never switched to / run in a live session**
- In the committed state both hosts are set to **Noctalia** (see Toggle below).

## Decisions made

- Drop hyprlock/hypridle; use Noctalia's lock screen + idle manager.
- Use Noctalia's default theme (`theme` left unset → builtin "Noctalia").
  Catppuccin for kitty/rofi is untouched.
- Workspace labels are the same Nerd Font glyphs as waybar's `format-icons`,
  shown via Hyprland `default_name` + Noctalia `label_source = "name"`.
- Keep TLP on carbonnix (40–80% charge thresholds). Use `tlp-pd` instead of
  power-profiles-daemon for Noctalia's power-profile switcher, and set
  UPower's `CHARGE_LIMIT` to TLP's values so Noctalia's "Use charge
  thresholds" toggle can't fight TLP (UPower's default is 75,80).
- Rebuild the hypernix waybar bars as one Noctalia bar template with a DP-3
  override.

## Toggle (one line per host + one NixOS line)

```nix
# home-manager/hypernix.nix  (same pattern in carbonnix.nix)
#./programs/window_manager/hypernix-classic.nix # waybar + dunst + hyprlock + hypridle
./programs/window_manager/hypernix-noctalia.nix # noctalia v5

# nixos/hosts/<host>/configuration.nix
../../desktop/noctalia.nix # comment out when going back to classic
```

## Steps completed

1. **Research** (v5 docs + source at noctalia 5.2.0): HM module
   `inputs.noctalia.homeModules.default` → `programs.noctalia.{enable,settings,systemd.enable,checkConfig}`;
   TOML config; `noctalia msg …` IPC; native idle (`[idle.behavior.*]`);
   `lockscreen.lock_before_suspend` defaults to true (covers lid close);
   charge-threshold toggle goes through UPower `EnableChargeThreshold`.
2. **flake.nix / flake.lock**: ~~added a `noctalia` flake input~~ (removed
   again on 2026-10-18; see Re-evaluation).
3. **Classic refactor (no behaviour change)**:
   - `hyprland.lua`: removed shell-specific lines; loads `shell.lua` via
     `pcall(require, "shell")` and calls `shell.autostart()` in the
     `hyprland.start` hook.
   - New `shell-classic.lua` (waybar/cliphist autostart, rofi, grimblast,
     dunstctl, hyprlock, playerctl/wpctl/brightnessctl binds) and
     `shell-classic.nix` (imports `waybar.nix` + `hyprlock.nix`, dunst service +
     config, catppuccin waybar/hyprlock).
   - Moved dunst out of `gui.nix`; moved waybar/hyprlock out of `catppuccin.nix`.
   - `window_manager/hypernix.nix` → `hypernix-classic.nix`,
     `carbonnix.nix` → `carbonnix-classic.nix`; each now imports
     `shell-classic.nix` + `hypridle.nix` with that host's timeouts.
   - `hypr/machine.lua` is now set in the host files
     (`home-manager/hypernix.nix`, `carbonnix.nix`) since both shells need it.
   - Suspend guard extracted to `suspend-if-idle.nix` (renamed from
     `hypridle-suspend-if-idle`), shared by hypridle and Noctalia.
4. **Noctalia modules**:
   - `shell-noctalia.nix`: HM's `programs.noctalia`, shared settings (idle
     actions, workspaces/taskbar/clock/sysmon widgets), ships `shell.lua`.
   - `shell-noctalia.lua`: `noctalia` autostart, glyph workspace names, IPC
     binds (Space launcher, V clipboard, A control center, comma settings,
     S screenshot-region, Y notification history, T/N clear, CTRL+L lock,
     media/volume/mic/brightness keys), settings-window float rule, blur
     layer rule, then `pcall(require, "shell_host")`.
   - `hypernix-noctalia.nix`: bar `main` (HDMI-A-1 full bar; `monitor.dp3`
     override = workspaces + taskbar only), idle 600/900/1800 s,
     `shell_host.lua` making workspaces 1–5 (HDMI-A-1) / 6–10 (DP-3) persistent.
   - `carbonnix-noctalia.nix`: laptop bar (media, battery, brightness,
     network, bluetooth, sysmon…), idle 300/600/1200 s, persistent 1/4/6/10.
   - `nixos/desktop/noctalia.nix`: upower; `tlp.pd` on TLP hosts else
     power-profiles-daemon; hwdb `CHARGE_LIMIT=<TLP start>,<TLP stop>`.
5. **Verification** (per CLAUDE.md dix procedure):
   - Pass 1 (refactor, classic active): both OS builds identical; HM only
     `+hypr/shell.lua` and the suspend-script rename. Line-level check
     confirmed nothing from the old `hyprland.lua` was lost.
   - Pass 2 (Noctalia active): builds OK, noctalia 5.2.0 from cachix,
     generated `config.toml` passed `checkConfig`. OS adds upower (+ppd on
     hypernix, `tlp-pd` on carbonnix). HM adds noctalia, removes waybar,
     dunst, hyprlock, hypridle, pavucontrol, nm-applet, mediastatus.
   - Built carbonnix hwdb queried with `systemd-hwdb --root=… query` →
     `CHARGE_LIMIT=40,80`.
   - `nix fmt` + `statix` clean on new/changed files.

## Re-evaluation (2026-10-18, upstream at v5.3.0)

- **Closure size → resolved: dropped the `noctalia` flake input.**
  home-manager-unstable now ships `programs.noctalia` (module moved upstream
  2026-09-30) and nixpkgs-unstable ships `pkgs.noctalia` (same
  `autoAddDriverRunpath` build). The pinned flake input actually broke the HM
  build: it predated upstream's `disabledModules` fix (#4656), so both modules
  declared the same options. Also removed the noctalia.cachix.org substituter.
  HM growth vs classic is now ~14 MiB instead of ~750 MiB. Trade-off: the
  version follows nixpkgs-unstable.
- **pavucontrol → re-added** (shell-noctalia.nix). **nm-applet → not re-added**:
  Noctalia registers its own NetworkManager secret agent, so a second agent
  would compete for Wi-Fi password prompts.
- **Wallpaper → use Noctalia's** (it ships a default `noctalia-wallpaper.png`;
  the picker reads `wallpaper.directory`, empty = XDG Pictures). Nothing set yet.
- **Tailscale → deferred** (no indicator for now). Investigated and tried,
  then removed to revisit later:
  - The network widget's `vpn_status` only sees NM vpn/wireguard connections,
    not `tailscale0`; `custom_button` is static (no polling).
  - Candidate: community plugin `davemhammer/tailscale` (carbonnix only, the
    only host with tailscale). Would be `plugins.enabled = [ "davemhammer/tailscale" ];`
    plus `"davemhammer/tailscale:status"` in `bar.main.end` (after `network`)
    and `jq` in `home.packages`; builds and passes `checkConfig`.
  - Concerns: fetched from the community git source at runtime, not pinned by
    Nix; needs a running `tailscaled` (not autostarted on carbonnix) and
    operator rights (`tailscale set --operator=$USER`). Widget settings
    `hide_when_healthy` / `flag_problem` may help match waybar's icon-only look.
- Re-ran the dix procedure. Baseline for HM was master `d5b5841` (classic),
  since the branch HEAD HM no longer built.

## Steps remaining

1. **Optional new 5.2.1/5.3.0 settings to consider**
   - [ ] hypernix: `notification.follow_focused_output` / `osd.follow_focused_output`.
   - [ ] carbonnix: `widget.media.hide_when_idle`.
   - [ ] carbonnix: Tailscale indicator (deferred, see Re-evaluation).
   - [x] Bumped nixpkgs-unstable (fe13242, 2026-10-15) → noctalia 5.3.0 (fixes:
     idle actions preserved when locking, lock-screen Suspend action, PAM retry
     loop, lock/suspend frame leaks). dix: only routine package bumps otherwise.
2. **Before switching**: rebase onto `master` if it has moved and re-run the
   dix procedure (as of 2026-10-18 `master` has no commits the branch lacks).
3. **Switch and test on hypernix**
   - [ ] `nixos-rebuild switch` + `home-manager switch`, log out/in.
   - [ ] Hyprland Lua loads cleanly: `shell.lua` / `shell_host.lua` are
     required, `hl.layer_rule` and `persistent = true` workspace rules are
     accepted (check `hyprctl` errors / Hyprland log).
   - [ ] Glyph workspace names render in the bar; DP-3 bar shows only
     workspaces + windows; workspaces stay on the right monitors.
   - [ ] Binds: launcher, clipboard panel, control center, settings,
     screenshot, notification history/clear, lock, media/volume/mic keys.
   - [ ] Idle: lock 10 min, screen off 15 min, suspend 30 min (and
     suspend is skipped during rsync/cp or remote login).
   - [ ] Notifications work (dunst gone, Noctalia daemon owns the bus name).
4. **Switch and test on carbonnix**
   - [ ] Same checks as above, plus battery/brightness widgets and keys.
   - [ ] Power-profile switcher works through `tlp-pd`.
   - [ ] `cat /sys/class/power_supply/BAT0/charge_control_{start,end}_threshold`
     → 40 / 80, and stays so after toggling Noctalia's "Use charge
     thresholds" (Control Center → Power).
   - [ ] Lid close locks before suspend.
5. **Follow-ups (optional)**: Noctalia theme templates for GTK/kitty;
   `noctalia msg config-reload` after HM switches; delete the classic files
   once Noctalia has proven itself (or keep as fallback).

## Useful references

- Docs: https://docs.noctalia.dev/noctalia/ (NixOS, bar, IPC, idle pages)
- Every default setting: `example.toml` in https://github.com/noctalia-dev/noctalia
- IPC list: `noctalia msg --help`
