{ osConfig, config, pkgs, lib, ... }:
let
  username = config.home.username;
  serviceName = "beszel-agent-${username}";
  svc = osConfig.local.services.${serviceName};
  version = svc.version;
  # Rootless-podman loopback fix: when the agent shares a host with the hub,
  # route beszel.localdomain through podman's host-gateway alias so traffic
  # reaches the hub via host loopback instead of hairpinning via the LAN IP.
  sameHostAsHub = osConfig.local.services ? beszel;
  hairpinFix = lib.optionalAttrs sameHostAsHub {
    networks = [ "pasta" ];
    addHosts = [ "beszel.localdomain:host-gateway" ];
  };
in
{
  systemd.user.sockets.podman = {
    Unit.Description = "Podman API Socket";
    Socket = {
      ListenStream = "%t/podman/podman.sock";
      SocketMode = "0660";
    };
    Install.WantedBy = [ "sockets.target" ];
  };

  systemd.user.services.podman = {
    Unit = {
      Description = "Podman API";
      Requires = [ "podman.socket" ];
      After = [ "podman.socket" ];
      StartLimitIntervalSec = "0";
    };
    Service = {
      Type = "exec";
      KillMode = "process";
      ExecStart = "${pkgs.podman}/bin/podman system service --time=0";
    };
  };

  virtualisation.quadlet = {
    enable = true;
    containers.beszel-agent = {
      autoStart = true;
      unitConfig = {
        Description = "Beszel monitoring agent (${username})";
        Wants = "network-online.target podman.socket";
        After = "network-online.target podman.socket";
      };
      containerConfig = {
        image = "docker.io/henrygd/beszel-agent:${version}";
        environments = {
          HUB_URL = "https://beszel.localdomain";
          SYSTEM_NAME = "${osConfig.networking.hostName}-${username}";
          DATA_DIR = "/data";
        };
        environmentFiles = [ "/run/secrets/rendered/beszel-agent-${username}.env" ];
        volumes = [
          "%t/podman/podman.sock:/var/run/docker.sock:ro"
          # Mount host CA bundle so the agent trusts the internal Caddy cert.
          "/etc/ssl/certs:/etc/ssl/certs:ro"
          # Persist the agent's identity keypair across container recreation.
          "beszel-agent-data:/data"
        ];
        dropCapabilities = [ "ALL" ];
        noNewPrivileges = true;
      } // hairpinFix;
      serviceConfig.Restart = "always";
    };
    volumes."beszel-agent-data" = { };
  };
}
