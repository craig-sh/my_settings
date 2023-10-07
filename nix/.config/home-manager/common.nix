{ config, pkgs, lib, ... }:

{
  imports = [
    ./programs/starship.nix
    ./programs/git.nix
    ./programs/tmux.nix
    ./programs/zsh.nix
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "craig";
  home.homeDirectory = "/home/craig";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  # Packages to install
  home.packages = [
    #  TODO nerdfont here
    # pkgs is the set of all packages in the default home.nix implementation
    pkgs.zsh
    pkgs.ripgrep
    # todo integrate with zsh
    pkgs.eza
    # neovim dependencies
    pkgs.tree-sitter
    pkgs.nodejs
    pkgs.nodePackages.npm
  ];

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    dircolors = {
      enable = true;
      enableZshIntegration = true;
    };
    bat.enable = true;
    neovim = {
      enable=true;
      viAlias = true;
      vimAlias = true;
      plugins = [
         (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
            p.org
            p.python
            p.bash
            p.vim
            p.lua
            p.javascript
            p.sql
            p.haskell
        ]))
      ];
    };
  };


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink "/home/craig/my_settings/nix/.config/home-manager/programs/neovim/init.lua";
    ".profile".source = programs/zsh/.profile;
    ".zprofile".source = programs/zsh/.zprofile;
    ".zsh_aliases".source = programs/zsh/.zsh_aliases;
  };


  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/craig/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
