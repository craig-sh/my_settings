{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (osConfig.local.services.notes) version;
  servicePort = toString osConfig.local.services.notes.port;
  internalPort = "8080";

  # Agents push markdown here; this host only ever pulls from it.
  repoUrl = "ssh://git@127.0.0.1:2222/craig-sh/notes.git";
  branch = "main";
  deployKey = osConfig.sops.secrets.notes-deploy-key.path;

  zensicalImage = "docker.io/zensical/zensical:${version}";

  dataDir = "${config.xdg.dataHome}/notes";
  siteDir = "${dataDir}/site";

  nginxConf = pkgs.writeText "notes-nginx.conf" ''
    server {
      listen ${internalPort};
      root /usr/share/nginx/html;
      # Caddy terminates TLS in front of us, so keep directory-slash redirects
      # relative instead of pointing at http://localhost:${internalPort}.
      absolute_redirect off;
      error_page 404 /404.html;

      gzip on;
      gzip_types text/css application/javascript application/json image/svg+xml;

      location = /health {
        access_log off;
        return 200;
      }
    }
  '';

  sync = pkgs.writeShellApplication {
    name = "notes-sync";
    runtimeInputs = with pkgs; [
      coreutils
      git
      openssh
      osConfig.virtualisation.podman.package
      rsync
    ];
    text = ''
      repo="${dataDir}/repo"
      stampFile="${dataDir}/built-stamp"
      export GIT_SSH_COMMAND="ssh -i ${deployKey} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=${dataDir}/known_hosts"

      if [ ! -d "$repo/.git" ]; then
        git clone --branch ${branch} ${repoUrl} "$repo"
      fi
      git -C "$repo" fetch --quiet --prune origin ${branch}
      # The clone is a read-only mirror, so a hard reset also copes with force pushes.
      git -C "$repo" reset --quiet --hard FETCH_HEAD
      # Builds take well under a second, so start clean rather than trusting a
      # .cache left behind by a different zensical version.
      git -C "$repo" clean --quiet -ffdx

      # Rebuild when either the content or the zensical version changes.
      stamp="$(git -C "$repo" rev-parse HEAD) ${zensicalImage}"
      if [ -f "$stampFile" ] && [ "$(cat "$stampFile")" = "$stamp" ]; then
        exit 0
      fi

      # Container root maps to this user, so site/ comes out owned by us. The
      # build needs nothing from the network.
      podman run --rm --pull=missing --network=none --read-only \
        --cap-drop=ALL --security-opt=no-new-privileges \
        -v "$repo:/docs" ${zensicalImage} build
      # On a failed build we exit above and keep serving the last good site.
      rsync -a --delete-after --delay-updates "$repo/site/" "${siteDir}/"
      echo "$stamp" > "$stampFile"
      echo "Built $(git -C "$repo" log -1 --format='%h %s')"
    '';
  };
in
{
  systemd.user = {
    tmpfiles.rules = [ "d ${siteDir} 0755 - - -" ];

    services.notes-sync = {
      Unit.Description = "Pull the notes repo and rebuild the static site";
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe sync;
        # A first run also pulls the zensical image; don't let a hung fetch or
        # pull pile up behind the timer forever.
        TimeoutStartSec = "10min";
      };
    };
    timers.notes-sync = {
      Unit.Description = "Periodically pull and rebuild the notes site";
      Timer = {
        OnBootSec = "1min";
        OnUnitActiveSec = "2min";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };

  virtualisation.quadlet = {
    enable = true;
    containers.notes = {
      containerConfig = {
        # The unprivileged image runs as uid 101 on 8080, so it needs no
        # capabilities back after dropping ALL.
        image = "docker.io/nginxinc/nginx-unprivileged:1.30-alpine";
        pull = "newer";
        publishPorts = [ "127.0.0.1:${servicePort}:${internalPort}" ];
        volumes = [
          "${siteDir}:/usr/share/nginx/html:ro"
          "${nginxConf}:/etc/nginx/conf.d/default.conf:ro"
        ];
        environments.NGINX_ENTRYPOINT_QUIET_LOGS = "1";
        # Podman's read-only mode still mounts tmpfs on /tmp, where this image
        # keeps its pid file and temp dirs.
        readOnly = true;
        dropCapabilities = [ "ALL" ];
        noNewPrivileges = true;
        healthCmd = "wget -q --spider http://127.0.0.1:${internalPort}/health";
        healthInterval = "60s";
        healthTimeout = "10s";
        healthRetries = 3;
        healthStartPeriod = "10s";
      };
      unitConfig.Description = "Notes static site";
      serviceConfig.Restart = "always";
    };
  };
}
