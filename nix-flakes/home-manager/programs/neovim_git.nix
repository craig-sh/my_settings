{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  programs.neovim = {
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
