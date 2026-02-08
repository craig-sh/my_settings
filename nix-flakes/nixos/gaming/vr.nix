_: {

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

  programs.envision = {
    enable = true;
    openFirewall = false; # This is set true by default
  };
}
