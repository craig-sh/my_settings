# System services used by the Noctalia v5 desktop shell (home-manager
# window_manager/shell-noctalia.nix). Comment out the import in the host's
# configuration.nix together with switching back to the classic shell.
{ config, lib, ... }:
let
  tlp = config.services.tlp;
  chargeStart = toString (tlp.settings.START_CHARGE_THRESH_BAT0 or "_");
  chargeStop = toString (tlp.settings.STOP_CHARGE_THRESH_BAT0 or "_");
in
{
  services = {
    # Battery status, charge-threshold toggle.
    upower.enable = true;

    # Noctalia's power-profile switcher talks to the power-profiles-daemon
    # D-Bus API. On TLP hosts use TLP's own implementation (tlp-pd) instead of
    # power-profiles-daemon, which conflicts with TLP.
    tlp.pd.enable = lib.mkIf tlp.enable true;
    power-profiles-daemon.enable = lib.mkIf (!tlp.enable) (lib.mkDefault true);

    # Noctalia's "Use charge thresholds" toggle asks UPower to apply its
    # CHARGE_LIMIT (UPower default 75,80). Match TLP's thresholds so toggling
    # it can't fight TLP.
    udev.extraHwdb = lib.mkIf (tlp.enable && tlp.settings ? STOP_CHARGE_THRESH_BAT0) ''
      battery:*:*:dmi:*
       CHARGE_LIMIT=${chargeStart},${chargeStop}
    '';
  };
}
