# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, inputs, pkgs, ... }:
let
  secretspath = builtins.toString inputs.mysecrets;
in
{
  imports = [
    #./steam-direct-login.nix
    #./zoneminder.nix
    # ./scrypted.nix
    #./frigate.nix
    ./beelink-backup.nix
  ];

  # load the secrets needed by this system
  sops.secrets.restic_password = {
    format = "yaml";
  };

  sops.secrets.oracle_vm_ssh_key = {
    format = "yaml";
  };
  sops.secrets.healthcheck_key = {
    format = "yaml";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "nfs" ];
  boot.kernel.sysctl = {
    # to allow rootless containers (frigate) to monitor performance
    "kernel.perf_event_paranoid" = 0;
  };


  #boot.kernelPackages = pkgs.linuxPackages_latest;
  nixpkgs.config.allowUnfree = true;

  hardware.firmware = [ pkgs.linux-firmware ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-media-sdk
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ intel-media-driver ];
  };


  networking.hostName = "beelink"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  # For frigate pod
  networking.firewall.allowedTCPPorts = [
    8096 # jellyfin
    8971 # frigate
    8554 # frigate
    8555 # frigate
    8556 # frigate
  ];
  networking.firewall.allowedUDPPorts = [
    7359 # jellyfin
    8555 # frigate
  ];

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.craig = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "video" "render"]; # Enable ‘sudo’ for the user. video/render is for hwaccell for rootless containers
    # Quadlets
    # required for auto start before user login
    linger = true;
    # required for rootless container with multiple users
    autoSubUidGidRange = true;
  };

  #users.users.jellyfin = {
  #  isSystemUser = true;
  #  uid = 1100;
  #  extraGroups = ["video" "render"]; # video/render is for hwaccell for rootless containers
  #  group =  "funmedia";
  #  # Quadlets
  #  # required for auto start before user login
  #  linger = true;
  #  # required for rootless container with multiple users
  #  autoSubUidGidRange = true;
  #};
  #users.groups.funmedia = {};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    age
    sops
    nfs-utils

    # hardwarde transcoding
    intel-compute-runtime-legacy1
    intel-gmmlib
    pciutils

  ];
  environment.shells = with pkgs; [ zsh ];
  environment.sessionVariables = {
    SOPS_AGE_KEY_FILE = "/var/lib/sops-nix/key.txt";
    LIBVA_DRIVER_NAME = "iHD";
  };

  #  help with podman debugging
  environment.etc."systemd/user-generators/podman-user-generator" = {
    source = "${pkgs.podman}/lib/systemd/user-generators/podman-user-generator";
    target = "systemd/user-generators/podman-user-generator";
  };
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  nix.settings.auto-optimise-store = true;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.groups.containers = {};
  users.users = {
    containers = {
      group = "containers";  # Assign the user to the group
      isSystemUser = true;
      subUidRanges = [
        { startUid = 100000; count = 65536; }
      ];
      subGidRanges = [
        { startGid = 100000; count = 65536; }
      ];
    };
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  security.pki.certificateFiles = [ "${secretspath}/secrets/ca.crt" ];
  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=3600
  '';
  virtualisation.quadlet.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

