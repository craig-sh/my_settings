{ config, ... }: {
  virtualisation.quadlet = {
    containers = {
      scrypted = {
        autoStart = true;
        unitConfig = {
          Description = "Scrypted container";
          Wants = "network-online.target";
          After = "network-online.target";
        };

        containerConfig = {
          image = "docker.io/koush/scrypted:latest";
          timezone = "America/Toronto";
          devices = [ "/dev/dri" ];
          userns = "auto";
          publishPorts = ["11080:11080"];
          #labels = {
          #  "io.containers.autoupdate" = "registry";
          #};
          volumes = [ "scrypted.volume:/server/volume:U,Z" ];
          networks = [ "host" ];
        };

        serviceConfig = {
          Restart = "always";
          TimeoutStartSec = "900";
        };

        #installConfig = {
        #  WantedBy = [ "multi-user.target" "default.target" ];
        #};
      };
    };

    # You'll also need to define the volume referenced above
    volumes = {
      "scrypted" = {
        # Add any specific volume configuration here if needed
      };
    };
  };

  networking.firewall.allowedTCPPorts = [10443];
}

