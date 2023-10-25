{ lib, config, pkgs, ... }:

let
  common = import ./common.nix {config=config; pkgs=pkgs; lib=lib;};
  overrides = {
    programs.zsh.shellAliases = {
      kubectl = "sudo k3s kubectl";
    };
  };
in
  common // overrides
