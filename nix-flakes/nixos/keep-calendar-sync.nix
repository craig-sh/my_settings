{ pkgs, config, ...}:
{

  systemd.user.timers."keep-calendar-sync" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Unit = "keep-calendar-sync.service";
    };
    unitConfig.ConditionUser = "craig";
  };
  systemd.user.services."keep-calendar-sync" = {
    path = [
      pkgs.devenv
      pkgs.direnv
      pkgs.uv
      pkgs.python313
      pkgs.git
      pkgs.openssh
      pkgs.curl
    ];
    unitConfig.ConditionUser = "craig";
    serviceConfig = {
      Type = "oneshot";
      User = "craig";
    };
   environment = {
      CALENDAR_CRED_FILE = config.sops.secrets.gcalender_creds.path;
      HEALTHCHECK_KEY_FILE = config.sops.secrets.user_healthcheck_key.path;
    };
    script = ''
      #!/usr/bin/env bash
      export KEEP_USER=$(cat ${config.sops.secrets.keep_user.path});
      export KEEP_PASS=$(cat ${config.sops.secrets.keep_pass.path});
      cd /home/craig/calendar-parser-ai;
      devenv shell;
      git pull;
      uv run python src/main.py "UPCOMING EVENTS";
      # Healthcheck
      curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/$(cat $HEALTHCHECK_KEY_FILE)/keep-calendar-sync;
    '';
  };

}
