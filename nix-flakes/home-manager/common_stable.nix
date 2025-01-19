# Any diffencenses between unstable and stable nix releases are here
{ pkgs, ... }:

{
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
  ];

}
