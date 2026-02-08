{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    environmentVariables = {
      HCC_AMDGPU_TARGET = "gfx1101"; # used to be necessary, but doesn't seem to anymore
      HSA_OVERRIDE_GFX_VERSION = "11.0.1";
    };
    rocmOverrideGfx = "11.0.1";
    host = "0.0.0.0";
  };
  services.open-webui.enable = true;
  networking.firewall.allowedTCPPorts = [ 11434 ];
}
