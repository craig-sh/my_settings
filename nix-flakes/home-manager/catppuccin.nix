_: {
  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "macchiato";
    kitty = {
      enable = true;
    };
    rofi = {
      enable = true;
    };
    hyprlock = {
      enable = true;
    };
    waybar = {
      enable = true;
      # New catppuccin module defaults to prependImport; our waybar_style.css
      # imports catppuccin.css directly, so keep generating that file.
      mode = "createLink";
    };
  };
}
