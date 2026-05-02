{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.containerHealthcheck;

  hmUsers = config.home-manager.users or { };

  collectFrom =
    user: quadlet:
    let
      containers = quadlet.containers or { };
      pods = quadlet.pods or { };
      mk =
        objs:
        lib.mapAttrsToList (_: obj: {
          inherit user;
          unit = "${obj._serviceName}.service";
        }) (lib.filterAttrs (_: obj: obj._autoStart or obj.autoStart) objs);
    in
    mk containers ++ mk pods;

  userUnits = lib.concatLists (
    lib.mapAttrsToList (user: hmCfg: collectFrom user (hmCfg.virtualisation.quadlet or { })) hmUsers
  );

  systemUnits = collectFrom null (config.virtualisation.quadlet or { });

  excluded = u: lib.elem u.unit cfg.excludeUnits;
  allUnits = lib.filter (u: !(excluded u)) (systemUnits ++ userUnits);

  unitTierMap = lib.foldl' (
    acc: svc:
    acc // (lib.listToAttrs (map (u: lib.nameValuePair u svc.tier) svc.units))
  ) { } (lib.attrValues config.local.services);

  unitsWithTier = map (u: u // { tier = unitTierMap.${u.unit} or "normal"; }) allUnits;
  unitsByTier = lib.groupBy (u: u.tier) unitsWithTier;

  tiers = [
    "critical"
    "normal"
  ];

  checkLine =
    u:
    if u.user == null then
      ''
        if ! systemctl is-active --quiet ${u.unit}; then
          echo "DOWN [${u.tier}]: ${u.unit}"
          failed_units="$failed_units ${u.unit}"
        fi''
    else
      ''
        if ! systemctl --user --machine=${u.user}@.host is-active --quiet ${u.unit}; then
          echo "DOWN [${u.tier}]: ${u.user}/${u.unit}"
          failed_units="$failed_units ${u.user}/${u.unit}"
        fi'';

  tierBlock =
    tier:
    let
      units = unitsByTier.${tier} or [ ];
    in
    lib.optionalString (units != [ ]) ''
      # === tier: ${tier} ===
      failed_units=""
      ${lib.concatMapStringsSep "\n" checkLine units}
      TIER_URL="https://hc-ping.com/$HEALTHCHECK_KEY/${cfg.slugPrefix}-${tier}"
      if [ -z "$failed_units" ]; then
        echo "OK [${tier}]: ${toString (lib.length units)} units active"
        curl -fsS -m 10 --retry 3 -o /dev/null "$TIER_URL"
      else
        echo "FAIL [${tier}]:$failed_units"
        curl -fsS -m 10 --retry 3 -o /dev/null --data-raw "down:$failed_units" "$TIER_URL/fail" || true
        overall_failed=1
      fi
    '';
in
{
  options.local.containerHealthcheck = {
    enable = lib.mkEnableOption "Periodic container liveness check that pings healthchecks.io";

    slugPrefix = lib.mkOption {
      type = lib.types.str;
      default = "${config.networking.hostName}-containers";
      defaultText = lib.literalExpression "\"\${config.networking.hostName}-containers\"";
      description = ''
        Prefix for the per-tier healthchecks.io ping slug.
        Final URL is `https://hc-ping.com/<healthcheck_key>/<slugPrefix>-<tier>`,
        e.g. `<slugPrefix>-critical` and `<slugPrefix>-normal`.
      '';
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      description = "How often to run the check (systemd OnUnitActiveSec format).";
    };

    startupDelay = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      description = "Delay after boot before the first check, to give containers time to start.";
    };

    excludeUnits = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Auto-discovered unit names to skip (e.g. \"foo.service\").";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.container-healthcheck = {
      description = "Verify expected containers are running and ping healthchecks.io";
      path = [
        pkgs.curl
        pkgs.systemd
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      environment = {
        HEALTHCHECK_KEY_FILE = config.sops.secrets.healthcheck_key.path;
      };
      script = ''
        set -uo pipefail

        HEALTHCHECK_KEY="$(cat "$HEALTHCHECK_KEY_FILE")"
        overall_failed=0

        ${lib.concatMapStringsSep "\n" tierBlock tiers}

        exit $overall_failed
      '';
    };

    systemd.timers.container-healthcheck = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = cfg.startupDelay;
        OnUnitActiveSec = cfg.interval;
        Unit = "container-healthcheck.service";
      };
    };
  };
}
