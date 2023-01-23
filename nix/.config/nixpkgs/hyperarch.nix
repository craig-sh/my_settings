{ config, pkgs, ... }:

let
  common = import ./common.nix {config=config; pkgs=pkgs;};
  overrides = {
  };
in
(common // overrides)

