# Any diffencenses between unstable and stable nix releases are here
{ pkgs, ... }:

{

  imports = [
    ./programs/git_unstable.nix
  ];
  home.packages = [
    pkgs.nerd-fonts.fantasque-sans-mono
  ];

}
