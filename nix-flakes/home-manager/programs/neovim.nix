{ pkgs, lib, config, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    # Commented out because of nixd security issue since its tied to old nix version
    #extraPackages = [
    #  pkgs.nixd
    #];
  };

  home.file = {
    ".config/nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink "/home/craig/my_settings/neovim/.config/nvim/init.lua";
    ".config/nvim/lua/tools.lua".text = ''
      return {
            gcc = '${lib.getExe pkgs.gcc}';
      }
    '';
  };
}
