# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{
  config,
  pkgs,
  inputs,
  ...
}:
let
  secretspath = builtins.toString inputs.mysecrets;
in
{
  imports = [ ];

  # load the secrets needed by this system
  sops.secrets = {
    k3s-server-token = {
      format = "yaml";
    };
    virtnix-tailscale-key = {
      format = "yaml";
    };
    restic_password = {
      format = "yaml";
    };
    healthcheck_key = {
      format = "yaml";
    };
  };

  #### Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  # Use the GRUB 2 boot loader.
  boot = {
    loader.grub = {
      enable = true;
      # Define on which hard drive you want to install Grub.
      device = "/dev/sda"; # or "nodev" for efi only
      configurationLimit = 10;
    };
    supportedFilesystems = [ "nfs" ];
  };

  #networking.hostName = "virtnix"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  #networking.extraHosts =
  #''
  #  127.0.0.1 beelink.localdomain
  #'';

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

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # for k8s nfs
  # Define a user account. Don't forget to set a password with 'passwd'.
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      craig = {
        isNormalUser = true;
        extraGroups = [ "wheel" ]; # Enable 'sudo' for the user.
        #packages = with pkgs; [
        #  firefox
        #  tree
        #];
      };
      media = {
        isNormalUser = false;
        isSystemUser = true;
        group = "media";
        uid = 995;
      };
      tandoor = {
        isNormalUser = false;
        isSystemUser = true;
        group = "tandoor";
        uid = 451;
      };
      paperless = {
        isNormalUser = false;
        isSystemUser = true;
        group = "paperless";
        uid = 452;
      };
      homelab = {
        isNormalUser = false;
        isSystemUser = true;
        group = "homelab";
        uid = 453;
      };
    };
    groups = {
      media = {
        gid = 995;
      };
      tandoor = {
        gid = 451;
      };
      paperless = {
        gid = 452;
      };
      homelab = {
        gid = 453;
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      git
      nfs-utils
      age
      sops
      restic
    ];
    shells = with pkgs; [ zsh ];
    sessionVariables = {
      SOPS_AGE_KEY_FILE = "/var/lib/sops-nix/key.txt";
    };
  };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    settings.auto-optimise-store = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.zsh.enable = true;

  security = {
    pki.certificateFiles = [ "${secretspath}/secrets/ca.crt" ];
    sudo.extraConfig = ''
      Defaults        timestamp_timeout=3600
    '';
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  #networking.firewall.enable = false;
  #services.k3s.enable = true;
  #services.k3s.role = "server";
  #services.k3s.extraFlags = toString [
  #  " --disable=traefik" # Optionally add additional args to k3s
  #  " --write-kubeconfig-mode=0644"
  #];
  services = {
    rpcbind.enable = true; # for k8s nfs
    openssh.enable = true;
    qemuGuest.enable = true;
  };

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
  system.stateVersion = "23.05"; # Did you read the comment?

}
