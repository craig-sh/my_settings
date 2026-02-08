{ lib, pkgs, ... }:
{
  #nixpkgs.config.packageOverrides = pkgs: {
  #    steam = pkgs.steam.override {
  #      extraPkgs = pkgs: with pkgs; [
  #        xorg.libXcursor
  #        xorg.libXi
  #        xorg.libXinerama
  #        xorg.libXScrnSaver
  #        libpng
  #        libpulseaudio
  #        libvorbis
  #        stdenv.cc.cc.lib
  #        libkrb5
  #        keyutils
  #      ];
  #    };
  #  };

  environment.systemPackages = with pkgs; [
    moonlight-qt
  ];
  services = {
    xserver = {
      enable = true;
      displayManager = {
        gdm.enable = true;
        autoLogin = {
          enable = true;
          user = "craig";
        };
      };
      #displayManager.lightdm.autoLogin.timeout = 10;
      desktopManager.gnome.enable = true;
    };
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
  programs = {
    gamescope.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
  };
  # Do we need this?
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
}
