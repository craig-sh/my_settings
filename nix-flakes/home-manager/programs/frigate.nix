{inputs, ...}: {
  imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];
  virtualisation.quadlet = {
    enable = true;
    containers = {
      frigate = {
        autoStart = true;
        unitConfig = {
          Description = "Frigate";
          Wants = "network-online.target nfs-client.target";
          After = "network-online.target nfs-client.target mnt-camera.mount";
        };

        containerConfig = {
          image = "ghcr.io/blakeblackshear/frigate:0.16.2";
          timezone = "America/Toronto";
          devices = [ "/dev/dri/renderD128" ];
          addGroups = ["keep-groups"];
          publishPorts = [
            "8971:8971"
            "8554:8554"
            "8555:8555/tcp"
            "8555:8555/udp"
          ];
          shmSize = "1024m";
          podmanArgs=["--privileged"];
          user = "0";
          userns = "keep-id";
          addCapabilities=["PERFMON"];
          tmpfses=["/tmp/cache:size=2000m"];
          volumes = [
            "frigate-config.volume:/config:U,Z"
            "/mnt/camera/frigate:/media/frigate"
          ];
          environments={
            LIBVA_DRIVER_NAME="iHD";
            #S6_CMD_WAIT_FOR_SERVICES_MAXTIME="20";
          };
          networks = [ "host" ];
        };

        serviceConfig = {
          Restart = "always";
        };
      };
    };
    volumes = {
      "frigate-config" = {
      };
    };
  };
}
