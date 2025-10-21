{config, ...}: {
  virtualisation.quadlet = {
    containers = {
      jellyfin = {
        autoStart = true;
        unitConfig = {
          Description = "Jellyfin";
          Wants = "network-online.target nfs-client.target";
          After = "network-online.target nfs-client.target";
        };

        containerConfig = {
          image = "ghcr.io/jellyfin/jellyfin:10.10.7";
          timezone = "America/Toronto";
          devices = [ "/dev/dri/renderD128" ];
          addGroups = ["keep-groups"];
          publishPorts = [
            "8096:8096/tcp"
            "7359:7359/udp"
          ];
          notify=true;
          user = "1000"; # Set in beelink-configuration.nix (jellyfin user id). # TODO does this even make sense to run under craig home-manager?
          userns = "keep-id";
          volumes = [
            "jellyfin-config.volume:/config:U"
            "jellyfin-cache:/cache:U"
            "/mnt/movies:/data/movies"
            "/mnt/tvshows:/data/tvshows"
          ];
          environments={
            LIBVA_DRIVER_NAME="iHD";
            #S6_CMD_WAIT_FOR_SERVICES_MAXTIME="20";
          };
        };

        serviceConfig = {
          SuccessExitStatus = "0 143";
          TimeoutStartSec = "infinity";
        };
      };
    };
    volumes = {
      "jellyfin-config" = { };
      "jellyfin-cache" = { };
    };
  };
}
