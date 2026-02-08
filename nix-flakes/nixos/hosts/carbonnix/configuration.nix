{ pkgs, ... }:

{
  imports = [
    #../../desktop/qtile-overlay.nix
    ../../desktop/qtile.nix
    ../../services/podman.nix
    ../../desktop/base-configuration.nix
    ../../desktop/x11.nix
    ../../hardware/laptop.nix
    ../../desktop/hyprland.nix
  ];

  #      (_: { nixpkgs.overlays = [ qtile-flake.overlays.default ]; })
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "carbonnix"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  # environment.systemPackages = [ ];
  services.displayManager.defaultSession = "qtile";
}
