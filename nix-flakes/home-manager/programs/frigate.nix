{ config, ... }: {
  virtualisation.quadlet = {
    autoEscape = true;
    containers = {
      frigate = {
        autoStart = true;
        unitConfig = {
          Description = "Frigate";
          Wants = "network-online.target nfs-client.target";
          After = "network-online.target nfs-client.target";
        };

        containerConfig = {
          image = "ghcr.io/blakeblackshear/frigate:stable";
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
          notify=true;
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
          TimeoutStartSec = "infinity";
        };

        #installConfig = {
        #  WantedBy = [ "multi-user.target" "default.target" ];
        #};
      };
      #neolink = {
      #  autoStart = true;
      #  unitConfig = {
      #    Description = "Neolink";
      #    Wants = "network-online.target";
      #    After = "network-online.target ";
      #  };

      #  containerConfig = {
      #    image = "quantumentangledandy/neolink";
      #    timezone = "America/Toronto";
      #    devices = [ "/dev/dri/renderD128" ];
      #    addGroups = ["keep-groups"];
      #    publishPorts = [
      #      "8556:8556"
      #    ];
      #    notify=true;
      #    podmanArgs=["--privileged"];
      #    user = "0";
      #    userns = "keep-id"; # TODO Hardocoded group to be same group as craig user on this machine
      #    volumes = [
      #      "/home/craig/.config/neolink.toml:/etc/neolink.toml"
      #    ];
      #    environments={
      #      LIBVA_DRIVER_NAME="iHD";
      #    };
      #    networks = [ "host" ];
      #  };

      #  serviceConfig = {
      #    Restart = "always";
      #    TimeoutStartSec = "900";
      #  };
      #};
    };

    # You'll also need to define the volume referenced above
    volumes = {
      "frigate-config" = {
        # Add any specific volume configuration here if needed
      };
    };
  };

#  home.file = {
#    ".config/neolink.toml".text = ''
#bind = "0.0.0.0"
#bind_port = 8556
#
#[[cameras]]
#name = "frontdoor"
#username = "admin"
#password = ""
#address = ""
#push_notifications=false
#
##[[cameras]]
##name = "driveway"
##username = "admin2"
##password = ""
##address = ""
##push_notifications=false
#    '';
#  };
}

