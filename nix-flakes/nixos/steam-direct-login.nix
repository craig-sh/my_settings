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
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.enable = true;
  programs.gamescope.enable = true;
  programs.steam.gamescopeSession.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "craig";
  #services.xserver.displayManager.lightdm.autoLogin.timeout = 10;
  # Do we need this?
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  #####
  programs.steam = {
    enable = true;
  };
  services.pipewire = {
     enable = true;
     pulse.enable = true;
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
}
