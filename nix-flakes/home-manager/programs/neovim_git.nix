{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  programs.neovim = {
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };
}
