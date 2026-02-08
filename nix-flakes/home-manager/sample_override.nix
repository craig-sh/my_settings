{
  lib,
  config,
  pkgs,
  ...
}:

let
  common = import ./common.nix {
    inherit config;
    inherit pkgs;
  };
  overrides = {
    programs.git = {
      userEmail = lib.mkForce "sample@sample.com";
    };
  };
in
common // overrides
