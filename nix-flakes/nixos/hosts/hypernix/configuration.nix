{ config, pkgs, ... }:

{
  imports = [
    ../../desktop/base-configuration.nix
    ../../desktop/wayland.nix
    ../../desktop/qtile.nix
    ../../gaming/gaming.nix
    ../../services/sunshine.nix
    ../../services/podman.nix
    ../../desktop/hyprland.nix
    #../../services/ai.nix
    #./gpu_passthrough.nix
    #../../desktop/x11.nix
    #../../desktop/kde.nix
    #../../gaming/vr.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "i2c-dev" ];
  boot.supportedFilesystems = [ "ntfs" ];
  hardware.i2c.enable = true;

  networking.hostName = "hypernix"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.interfaces.eno1.wakeOnLan.enable = true;

  environment.systemPackages = [
    pkgs.ddcutil
    pkgs.dmidecode
  ];

  services.udev.extraRules = ''
    # Issues with suspend, disable pci and usbs from waking system...just use the power button
    ACTION=="add", SUBSYSTEM=="pci", DRIVERS=="pcieport", ATTR{power/wakeup}="disabled"
    # blacklist for usb autosuspend. Could be cause of hyprland lockup: https://github.com/hyprwm/Hyprland/issues/2789
    ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTR{power/wakeup/autosuspend}="disabled"
  '';
  services.logind.settings.Login.HandlePowerKey = "suspend";
  services.xserver.deviceSection = ''
    Option "VariableRefresh" "true"
    Option "AsyncFlipSecondaries" "true"
  '';

  # For steam play

  networking.firewall.allowedTCPPorts = [
    27036
    27037
  ];
  networking.firewall.allowedUDPPorts = [
    27031
    27036
  ];

}
