{
  pkgs,
  lib,
  config,
  ...
}:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    # Currently breaking. When below is set we actually use the latest neovim from git
    # package = pkgs.neovim;
    # magick is for images in nvim
    extraLuaPackages = ps: [ ps.magick ];
    extraPackages = [
      pkgs.nixd
      pkgs.imagemagick
      pkgs.nixfmt-rfc-style
    ];
  };
  xdg.configFile."nvim/init.lua".enable = false; # disable the auto generated init.lua
  home.file = {
    ".config/nvim/init.lua".source =
      config.lib.file.mkOutOfStoreSymlink "/home/craig/my_settings/neovim/.config/nvim/init.lua";
    ".config/nvim/lua/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/craig/my_settings/neovim/.config/nvim/lua/config";
      recursive = true;
    };
    ".config/nvim/lua/plugins" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/craig/my_settings/neovim/.config/nvim/lua/plugins";
      recursive = true;
    };
    ".config/nvim/after".source =
      config.lib.file.mkOutOfStoreSymlink "/home/craig/my_settings/neovim/.config/nvim/after";
    ".config/nvim/mysnips".source =
      config.lib.file.mkOutOfStoreSymlink "/home/craig/my_settings/neovim/.config/nvim/mysnips";
    ".config/nvim/lua/tools.lua".text = ''
      return {
            gcc = '${lib.getExe pkgs.gcc}';
      }
    '';
  };
}
