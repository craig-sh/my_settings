{ inputs, ... }:

{
  imports = [
    inputs.quadlet-nix.homeManagerModules.quadlet
    ./programs/frigate.nix
  ];
}
