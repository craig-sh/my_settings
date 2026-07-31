{ config, osConfig, ... }:
let
  version = osConfig.local.services.photon.version;
  servicePort = toString osConfig.local.services.photon.port;
  internalPort = "2322";

  inherit (config.virtualisation.quadlet) pods networks;
in
{
  virtualisation.quadlet = {
    enable = true;

    # Shared with dawarichpod so dawarich can reach photon by pod name over
    # aardvark-dns. host.containers.internal is not an option: podman maps it to
    # 169.254.1.2 but pasta does not forward that to the host loopback, so a
    # 127.0.0.1-published port is unreachable from another pod. Declared in
    # dawarich.nix too - identical definitions merge - so neither module depends
    # on the other being enabled.
    networks."dawarich-net" = { };

    pods.photonpod = {
      podConfig = {
        publishPorts = [ "127.0.0.1:${servicePort}:${internalPort}" ];
        networks = [ networks."dawarich-net".ref ];
      };
      autoStart = true;
    };

    containers.photon = {
      containerConfig = {
        pod = pods.photonpod.ref;
        image = "docker.io/rtuszik/photon-docker:${version}";
        pull = "newer";
        # No capability hardening here - the image entrypoint runs as root and
        # does groupmod/usermod/chown -R before dropping to the photon user via
        # gosu, so it needs the default capability set.
        volumes = [ "photon-data:/photon/data" ];
        environments = {
          # Prebuilt index for Canada: ~8.3GiB download, ~14GiB on disk.
          # Coordinates outside Canada will not reverse geocode against it.
          REGION = "canada";
          # db = download a prebuilt index. The jsonl importer is upstream's
          # experimental mode and has no scheduled updates.
          IMPORT_MODE = "db";
          # SEQUENTIAL replaces the index in place; PARALLEL would need double
          # the disk for no benefit at this index size.
          UPDATE_STRATEGY = "SEQUENTIAL";
          # Upstream asks for long intervals to spare the community mirrors.
          UPDATE_INTERVAL = "720h";
          # Bound the JVM heap - beelink only has 16GB and also runs frigate.
          # The index is mmap'd, so the OS page cache does the real work.
          JAVA_PARAMS = "-Xmx2g";
          LOG_LEVEL = "INFO";
        };
      };
      unitConfig.Description = "Photon Reverse Geocoder";
      serviceConfig.Restart = "always";
    };

    volumes."photon-data" = { };
  };
}
