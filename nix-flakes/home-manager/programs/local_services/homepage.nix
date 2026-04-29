{
  pkgs,
  lib,
  osConfig,
  outputs,
  ...
}:
let
  version = osConfig.local.services.homepage.version;
  servicePort = toString osConfig.local.services.homepage.port;
  internalPort = "3000";
  homepageDomain = osConfig.local.services.homepage.domain;
  ourHost = osConfig.networking.hostName;

  hasEnvFile = osConfig.sops.templates ? "homepage.env";
  envFilePath = "/run/secrets/rendered/homepage.env";

  hostsWithServices = lib.filterAttrs (
    _: hostCfg: lib.hasAttrByPath [ "local" "services" ] hostCfg.config
  ) outputs.nixosConfigurations;

  resolveWidget =
    sameHost: svc:
    let
      autoUrl = lib.optionalAttrs (!(svc.widget ? url)) {
        url =
          if sameHost then
            "http://host.containers.internal:${toString svc.port}"
          else
            "https://${svc.domain}";
      };
    in
    autoUrl // svc.widget;

  mkTile =
    entry:
    {
      ${entry.svcName} = {
        href = "https://${entry.svc.domain}";
      } // lib.optionalAttrs (entry.svc.widget != null) {
        widget = resolveWidget entry.sameHost entry.svc;
      };
    };

  allServices = lib.concatLists (
    lib.mapAttrsToList (
      hostName: hostCfg:
      let
        sameHost = hostName == ourHost;
        services = lib.filterAttrs (
          n: svc: n != "homepage" && svc.caddy.enable
        ) hostCfg.config.local.services;
      in
      lib.mapAttrsToList (svcName: svc: { inherit svcName svc sameHost; }) services
    ) hostsWithServices
  );

  sortByName = lib.sort (a: b: a.svcName < b.svcName);

  withWidgets = lib.filter (e: e.svc.widget != null) allServices;
  withoutWidgets = lib.filter (e: e.svc.widget == null) allServices;

  byCategory = lib.groupBy (
    e: if e.svc.category != null then e.svc.category else "Other"
  ) withWidgets;

  categoryGroups = lib.mapAttrsToList (cat: items: {
    ${cat} = map mkTile (sortByName items);
  }) byCategory;

  linksGroup = lib.optional (withoutWidgets != [ ]) {
    Links = map mkTile (sortByName withoutWidgets);
  };

  servicesYaml = pkgs.writeText "services.yaml" (builtins.toJSON (
    categoryGroups ++ linksGroup
  ));

  settingsYaml = pkgs.writeText "settings.yaml" (builtins.toJSON {
    title = "Homepage";
    layout = {
      Links = {
        style = "row";
        columns = 4;
      };
    };
  });
in
{
  virtualisation.quadlet = {
    enable = true;
    containers.homepage = {
      autoStart = true;
      unitConfig = {
        Description = "Homepage Dashboard";
        Wants = "network-online.target";
        After = "network-online.target";
      };
      containerConfig = {
        image = "ghcr.io/gethomepage/homepage:${version}";
        user = "0:0";
        publishPorts = [
          "127.0.0.1:${servicePort}:${internalPort}/tcp"
        ];
        environments = {
          TZ = "America/Toronto";
          HOMEPAGE_ALLOWED_HOSTS = homepageDomain;
          NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/internal-ca.crt";
        };
        environmentFiles = lib.optional hasEnvFile envFilePath;
        volumes = [
          "homepage-config:/app/config"
          "${servicesYaml}:/app/config/services.yaml:ro"
          "${settingsYaml}:/app/config/settings.yaml:ro"
          "${osConfig.sops.secrets.ca_pub_cert.path}:/etc/ssl/certs/internal-ca.crt:ro"
        ];
      };
      serviceConfig.Restart = "always";
    };
    volumes."homepage-config" = { };
  };
}
