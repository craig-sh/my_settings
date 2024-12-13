{ config, pkgs, ... }:

{
  imports = [
    ./desktop-base-configuration.nix
    ./x11.nix
    ./qtile-overlay.nix
    ./gaming.nix
    #./gpu_passthrough.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = ["i2c-dev"];
  boot.supportedFilesystems = [ "ntfs" ];
  hardware.i2c.enable = true;

  networking.hostName = "hypernix"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  #networking.extraHosts =
  #''
  #  127.0.0.1 beelink.localdomain
  #'';

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "craig";

  environment.systemPackages = [
    pkgs.ddcutil
    pkgs.dmidecode
  ];

  # Issues with suspend, disable pci and usbs from waking system...just use the power button
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVERS=="pcieport", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTR{power/wakeup}="disabled"
  '';
  services.logind.powerKey = "suspend";
  #services.xserver.deviceSection = ''
  #    Option "VariableRefresh" "true"
  #    Option "AsyncFlipSecondaries" "true"
  #'';

  # For steam play

  networking.firewall.allowedTCPPorts = [ 27036 27037 ];
  networking.firewall.allowedUDPPorts = [ 27031 27036 ];

  # VR https://wiki.nixos.org/wiki/VR
  services.monado = {
    enable = true;
    defaultRuntime = true; # Register as default OpenXR runtime
  };
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    WMR_HANDTRACKING = "0"; # disable handtrackiong for now
  };

}
