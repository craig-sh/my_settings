# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

let
    myCustomLayout = pkgs.writeText "xkb-layout" ''
      ! Unmap capslock
      clear Lock
      keycode 66 = Mode_switch

      !keycode 66 = Hyper_L
      !! Leave mod4 as windows key _only_
      !remove mod4 = Hyper_L
      !! Set mod3 to capslock
      !add mod3 = Hyper_L

      keysym h = h H Left
      keysym l = l L Right
      keysym k = k K Up
      keysym j = j J Down

      keysym a = a A End
      keysym b = b B Home
      keysym d = d D Next
      keysym u = u U Prior

      !! Comment out until qtile bug is fixed
      !! keysym t = t T XF86AudioRaiseVolume
      !! keysym s = s S XF86AudioLowerVolume
      !! keysym w = w W XF86AudioPlay
      !! keysym q = q Q XF86AudioPrev
      !! keysym e = e E XF86AudioNext

      !! keysym grave = Escape asciitilde grave
      keysym BackSpace = BackSpace BackSpace Delete
    '';
in {
  imports = [
    ./syncthing.nix
  ];

  users.users.craig = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      git
    ];
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };
  nixpkgs.config.allowUnfree = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.qtile = {
    enable = true;
    extraPackages = python3Packages: with python3Packages; [
      qtile-extras
      pulsectl-asyncio
    ];
    configFile = "/home/craig/.config/qtile/config.py";
  };
  #services.xserver.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "none+qtile";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "craig";
  #   this should be only on laptop?
  # services.xserver.displayManager.sessionCommands = "${pkgs.xorg.xmodmap}/bin/xmodmap ${myCustomLayout}";
  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    age
    sops
    kitty
    firefox
    keepassxc
    xclip
    xsel
    iwd
    usbutils
    lm_sensors
    libnotify
    pciutils
    xdg-utils
    xdg-launch
    (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
  ];
  environment.shells = with pkgs; [ zsh ];
  environment.sessionVariables = {
    SOPS_AGE_KEY_FILE = "/home/craig/.config/sops/age/keys.txt";
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  # Perform garbage collection weekly to maintain low disk usage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  nix.settings.auto-optimise-store = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.fwupd.enable = true;

  security.pki.certificateFiles = [ ../secrets/ca.crt ];
  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=3600
  '';

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  #system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}

