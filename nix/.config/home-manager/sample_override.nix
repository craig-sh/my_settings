{ lib, config, pkgs, ... }:

let
  common = import ./common.nix {config=config; pkgs=pkgs;};
  overrides = {
    programs.git = {
        userEmail = lib.mkForce "sample@sample.com";
    };
  };
in
  common // overrides
