{ inputs, lib, ... }:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.catppuccin.homeModules.catppuccin
    ./common.nix
    ./common_unstable.nix
    ./gui.nix
    ./catppuccin.nix
    #./x11gui.nix
    #./programs/aider.nix
    ./programs/neovim_git.nix
    ./programs/claude-skills.nix
    ./programs/window_manager/hyprland.nix
    # Desktop shell: keep exactly one of these uncommented.
    #./programs/window_manager/carbonnix-classic.nix # waybar + dunst + hyprlock + hypridle
    ./programs/window_manager/carbonnix-noctalia.nix # noctalia v5
  ];

  # Per-machine Hyprland Lua config. hyprland.lua loads this via
  # require("machine").
  xdg.configFile."hypr/machine.lua".text = lib.fileContents ./programs/window_manager/carbonnix.lua;
}
