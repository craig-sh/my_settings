{ lib, pkgs, ... }:
{
    services.tailscale.enable = true;
    networking.firewall.allowedUDPPorts = [ 41641 ];
    environment.systemPackages = with pkgs; [ tailscale ];
    # Dont autostart tailscale
    systemd.services.tailscaled.wantedBy = lib.mkForce [];
}
