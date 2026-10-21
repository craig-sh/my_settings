{ pkgs, lib, ... }:

{
  imports = [
    #../../desktop/qtile-overlay.nix
    #../../desktop/qtile.nix
    ../../services/podman.nix
    ../../desktop/base-configuration.nix
    ../../desktop/x11.nix
    ../../hardware/laptop.nix
    ../../desktop/hyprland.nix
    ../../desktop/noctalia.nix # enable with the home-manager <host>-noctalia.nix shell
  ];

  #      (_: { nixpkgs.overlays = [ qtile-flake.overlays.default ]; })
  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "ntfs" ];
  };

  networking = {
    hostName = "carbonnix"; # Define your hostname.
    # Pick only one of the below networking options.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };
  # environment.systemPackages = [ ];
  services.displayManager.defaultSession = lib.mkForce "hyprland";
}
