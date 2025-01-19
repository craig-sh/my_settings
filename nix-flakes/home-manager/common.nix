{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./programs/starship.nix
    ./programs/git.nix
    ./programs/tmux.nix
    ./programs/zsh.nix
    ./programs/neovim.nix
    inputs.sops-nix.homeManagerModules.sops
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

  fonts.fontconfig.enable = true;
  # The home.packages option allows you to install Nix packages into your
  # environment.
  # Packages to install
  home.packages = [
    pkgs.zsh
    pkgs.ripgrep
    # todo integrate with zsh
    pkgs.eza
    pkgs.kubernetes-helm
    pkgs.just
    pkgs.kubectl
    pkgs.ruff
    (pkgs.python312.withPackages (ppkgs: [
      ppkgs.mypy
      ppkgs.python-lsp-server
      ppkgs.pylsp-mypy
      ppkgs.python-lsp-ruff
    ]))
    pkgs.nixpkgs-fmt
    pkgs.gcc # For neovim treesitter to compile parsers
    pkgs.btop
    pkgs.htop
    pkgs.fd
    pkgs.nodePackages.bash-language-server
    pkgs.lua-language-server
  ];

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
      tmux = {
        enableShellIntegration = true;
      };
    };
    dircolors = {
      enable = true;
      enableZshIntegration = true;
    };
    bat.enable = true;
    k9s.enable = true;
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = { };


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

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes" ];
  };
}
