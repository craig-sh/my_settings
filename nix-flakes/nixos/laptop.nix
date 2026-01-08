{ lib,pkgs, ... }:
{

  imports = [
    ./generic-key-remapping.nix
    ./tailscale.nix
  ];
  # Dont auto start sshd on laptops
  #systemd.services.sshd.wantedBy = lib.mkForce [ ];
  services.libinput.enable = true;
  services.blueman.enable = true;
  powerManagement.enable = true;
  services.thermald.enable = true;
  services.tlp = {
       enable = true;
       settings = {
         #CPU_SCALING_GOVERNOR_ON_AC = "performance";
         #CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

         #CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
         #CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

         #CPU_MIN_PERF_ON_AC = 0;
         #CPU_MAX_PERF_ON_AC = 100;
         #CPU_MIN_PERF_ON_BAT = 0;
         #CPU_MAX_PERF_ON_BAT = 20;

        #Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
       };
  };
  environment.systemPackages = with pkgs; [ brightnessctl ];
  hardware.bluetooth.enable = true;


  systemd.sleep.extraConfig = ''
    HibernateDelaySec=60min
  '';
  services.logind.lidSwitch = "suspend-then-hibernate";

}
