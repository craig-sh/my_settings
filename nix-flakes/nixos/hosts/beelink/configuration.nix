# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  secretspath = builtins.toString inputs.mysecrets;
in
{
  imports = [
    #../../gaming/steam-direct-login.nix
    #../../services/zoneminder.nix
    # ../../services/scrypted.nix
    #./frigate.nix
    ./backup.nix
    ../../services/caddy.nix
  ];

  # load the secrets needed by this system
  sops.secrets = {
    restic_password = {
      format = "yaml";
    };
    oracle_vm_ssh_key = {
      format = "yaml";
    };
    healthcheck_key = {
      format = "yaml";
    };
    ca_pub_cert = {
      format = "yaml";
      owner = config.systemd.services.caddy.serviceConfig.User;
    };
    ca_cert_key = {
      format = "yaml";
      owner = config.systemd.services.caddy.serviceConfig.User;
    };

    gf-redis-pw = {
      format = "yaml";
      owner = "conrun";
    };
    gf-pg-pw = {
      format = "yaml";
      owner = "conrun";
    };
    gf-gf-salt = {
      format = "yaml";
      owner = "conrun";
    };
    gf-gf-jwt = {
      format = "yaml";
      owner = "conrun";
    };

    sf-db-pw = {
      format = "yaml";
      owner = "conrun";
    };
    sf-app-db-pw = {
      format = "yaml";
      owner = "conrun";
    };
    sf-api-key = {
      format = "yaml";
      owner = "conrun";
    };
    sf-auth-secret = {
      format = "yaml";
      owner = "conrun";
    };
  };
  # TODO move this to home manager config?
  #  Do not double qoute below strings. This is passed to systemd enviornment not regular bash env!!!!!
  sops.templates."ghostfolio.env" = {
    content = ''
      REDIS_HOST=gfredis
      REDIS_PORT=6379
      REDIS_PASSWORD=${config.sops.placeholder.gf-redis-pw}

      POSTGRES_USER=pguser
      POSTGRES_DB=ghostfolio-db
      POSTGRES_PASSWORD=${config.sops.placeholder.gf-pg-pw}

      ACCESS_TOKEN_SALT=${config.sops.placeholder.gf-gf-salt}
      DATABASE_URL=postgresql://pguser:${config.sops.placeholder.gf-pg-pw}@gfpostgres:5432/ghostfolio-db?connect_timeout=300&sslmode=prefer
      JWT_SECRET_KEY=${config.sops.placeholder.gf-gf-jwt}
    '';
    owner = "conrun";
  };
  # Do not double quote below strings. This is passed to systemd environment not regular bash env!!!!!
  sops.templates."sparkyfitness.env" = {
    content = ''
      POSTGRES_DB=sparkydb
      POSTGRES_USER=sparky
      POSTGRES_PASSWORD=${config.sops.placeholder.sf-db-pw}

      SPARKY_FITNESS_DB_USER=sparky
      SPARKY_FITNESS_DB_NAME=sparkydb
      SPARKY_FITNESS_DB_HOST=sfpostgres
      SPARKY_FITNESS_DB_PORT=5432
      SPARKY_FITNESS_DB_PASSWORD=${config.sops.placeholder.sf-db-pw}

      SPARKY_FITNESS_APP_DB_USER=sparkyapp
      SPARKY_FITNESS_APP_DB_PASSWORD=${config.sops.placeholder.sf-app-db-pw}

      SPARKY_FITNESS_API_ENCRYPTION_KEY=${config.sops.placeholder.sf-api-key}
      BETTER_AUTH_SECRET=${config.sops.placeholder.sf-auth-secret}

      SPARKY_FITNESS_FRONTEND_URL=https://sparkyfitness.localdomain
      SPARKY_FITNESS_SERVER_HOST=sfserver
      SPARKY_FITNESS_SERVER_PORT=3010
    '';
    owner = "conrun";
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "nfs" ];
    kernel.sysctl = {
      # to allow rootless containers (frigate) to monitor performance
      "kernel.perf_event_paranoid" = 0;
    };
  };

  #boot.kernelPackages = pkgs.linuxPackages_latest;
  nixpkgs.config.allowUnfree = true;

  hardware.firmware = [ pkgs.linux-firmware ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # VA-API
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ intel-media-driver ];
  };

  networking = {
    hostName = "beelink"; # Define your hostname.
    # Pick only one of the below networking options.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
    firewall = {
      allowedTCPPorts = [
        8096 # jellyfin
      ];
      allowedUDPPorts = [
        7359 # jellyfin
      ];
    };
  };

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

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users = {
    craig = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [
        "wheel"
        "video"
        "render"
      ]; # Enable 'sudo' for the user. video/render is for hwaccell for rootless containers
      # Quadlets
      # required for auto start before user login
      linger = true;
      # required for rootless container with multiple users
      autoSubUidGidRange = true;
    };

    conrun = {
      isNormalUser = true;
      uid = 1010;
      #extraGroups = ["video" "render"]; # video/render is for hwaccell for rootless containers
      #group =  "funmedia";
      # Quadlets
      # required for auto start before user login
      linger = true;
      # required for rootless container with multiple users
      autoSubUidGidRange = true;
    };

    #jellyfin = {
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
  };
  #users.groups.funmedia = {};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
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
    shells = with pkgs; [ zsh ];
    sessionVariables = {
      SOPS_AGE_KEY_FILE = "/var/lib/sops-nix/key.txt";
      LIBVA_DRIVER_NAME = "iHD";
    };

    #  help with podman debugging
    etc."systemd/user-generators/podman-user-generator" = {
      source = "${pkgs.podman}/lib/systemd/user-generators/podman-user-generator";
      target = "systemd/user-generators/podman-user-generator";
    };
  };
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    settings.auto-optimise-store = true;
  };

  programs.zsh.enable = true;
  users = {
    defaultUserShell = pkgs.zsh;
    groups.containers = { };
    users = {
      containers = {
        group = "containers"; # Assign the user to the group
        isSystemUser = true;
        subUidRanges = [
          {
            startUid = 100000;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 100000;
            count = 65536;
          }
        ];
      };
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
  security = {
    pki.certificateFiles = [ "${secretspath}/secrets/ca.crt" ];
    sudo.extraConfig = ''
      Defaults        timestamp_timeout=3600
    '';
  };
  virtualisation.quadlet.enable = true;

  local.services = {
    forgejo = {
      port = 3001;
      domain = "git.localdomain";
      firewall.extraTCPPorts = [ 2222 ];
      backup.enable = true;
    };
    ghostfolio = {
      port = 3333;
      backup.enable = true;
      backup.scriptFile = null;
      backup.pgDumps = [ { container = "gfpostgres"; } ];
    };
    actualbudget = {
      port = 5006;
      backup.enable = true;
    };
    frigate = {
      user = "craig";
      port = 8971;
      firewall.extraTCPPorts = [ 8971 8554 8555 8556 ];
      firewall.extraUDPPorts = [ 8555 ];
      backup.enable = true;
    };
    sparkyfitness = {
      port = 3004;
      backup.enable = true;
      backup.pgDumps = [ { container = "sfpostgres"; } ];
    };
  };

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
