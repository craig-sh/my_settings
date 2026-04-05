{ pkgs, ... }:
{
  systemd.timers.sync-from-github = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 00/12:00:00";
      Unit = "sync-from-github.service";
    };
  };

  systemd.services.sync-from-github = {
    path = [ pkgs.git pkgs.openssh ];
    serviceConfig = {
      Type = "oneshot";
      User = "craig";
    };
    script = ''
      TMPDIR=$(${pkgs.coreutils}/bin/mktemp -d)
      trap "${pkgs.coreutils}/bin/rm -rf $TMPDIR" EXIT

      cd $TMPDIR
      git clone --bare ssh://git@git.localdomain:2222/craig-sh/my_settings.git repo
      cd repo
      git fetch https://github.com/craig-sh/my_settings.git master

      LOCAL=$(git rev-parse master)
      REMOTE=$(git rev-parse FETCH_HEAD)

      if [ "$LOCAL" = "$REMOTE" ]; then
        echo "master: already in sync"
      elif git merge-base --is-ancestor $LOCAL $REMOTE; then
        echo "master: GitHub is ahead, fast-forwarding"
        git push origin FETCH_HEAD:refs/heads/master
      elif git merge-base --is-ancestor $REMOTE $LOCAL; then
        echo "master: Forgejo is ahead, nothing to do"
      else
        echo "ERROR: master has diverged — manual intervention required"
        exit 1
      fi
    '';
  };
}
