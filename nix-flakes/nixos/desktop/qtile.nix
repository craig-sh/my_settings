{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.xserver.windowManager.qtile = {
    enable = true;
    extraPackages =
      python3Packages: with python3Packages; [
        qtile-extras
        pulsectl-asyncio
      ];
    configFile = "/home/craig/.config/qtile/config.py";
  };
  #services.xserver.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "qtile";
}
