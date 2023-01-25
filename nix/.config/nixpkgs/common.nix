{ config, pkgs, ... }:

{
  imports = [
    ./programs/starship.nix
    ./programs/git.nix
    ./programs/tmux.nix
    ./programs/zsh.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "craig";
  home.homeDirectory = "/home/craig";

  # Packages to install
  home.packages = [
    # pkgs is the set of all packages in the default home.nix implementation
    pkgs.zsh
    pkgs.ripgrep
    # todo integrate with zsh
    pkgs.exa
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
  };
  # zsh
  home.file.".profile".source = ../../../zsh/.profile;
  home.file.".zprofile".source = ../../../zsh/.zprofile;
  home.file.".zsh_aliases".source = ../../../zsh/.zsh_aliases;
  #home.file.".zshenv".source = ../../../zsh/.zshenv;
  #home.file.".zshrc".source = ../../../zsh/.zshrc;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


  #nixpkgs.overlays = [
  #  (import (builtins.fetchTarball {
  #    url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
  #  }))
  #];
  #programs.neovim = {
  #  enable = true;
  #  package = pkgs.neovim-nightly;
  #  extraPackages = with pkgs; [
  #    tree-sitter
  #  ];
  #};
}
