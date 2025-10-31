# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ inputs, pkgs,lib, options, ... }:
let
  secretspath = builtins.toString inputs.mysecrets;
in
{
  imports = [
    ./syncthing.nix
  ];

  users.users.craig = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "i2c"];
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

  #   this should be only on laptop?
  # Configure keymap in X11
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

  services.flatpak.enable = true;
  services.flatpak.remotes = lib.mkOptionDefault [{
    name = "flathub-beta";
    location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
  }];
  # This flatpak is our of date
  services.flatpak.packages = [
    { appId = "com.budgetwithbuckets.Buckets"; origin = "flathub-beta";  }
  ];
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    age
    sops
    xclip
    xsel
    iwd
    usbutils
    lm_sensors
    libnotify
    pciutils
    xdg-utils
    xdg-launch
    dconf # for gnome themes
    nfs-utils
  ];
  fonts.packages = [
    pkgs.nerd-fonts.fantasque-sans-mono
  ];
  environment.shells = with pkgs; [ zsh ];
  environment.sessionVariables = {
    SOPS_AGE_KEY_FILE = "/home/craig/.config/sops/age/keys.txt";
  };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  nix.settings.trusted-users = [ "craig" ];
  # Perform garbage collection weekly to maintain low disk usage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
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

  # https://nix.dev/guides/faq#how-to-run-non-nix-executables
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = options.programs.nix-ld.libraries.default;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.fwupd.enable = true;
  # Automount disks
  services.udisks2.enable = true;

  security.pki.certificateFiles = [ "${secretspath}/secrets/ca.crt" ];
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

