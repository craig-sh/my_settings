{ lib, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = lib.mkDefault "craig-sh";
      user.email = lib.mkDefault "craig.s.henriques@gmail.com";
      alias = {
        # https://git-scm.com/docs/git-reset#git-reset-emgitresetemltmodegtltcommitgt
        # Undo last commit
        undo = "reset --soft HEAD^";

        # We wanna grab those pesky un-added files!
        # https://git-scm.com/docs/git-stash
        stash-all = "stash save --include-untracked";

        # Fancier log, one line per commit
        glog = "log -n20 --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";

        ffmerge = "merge --ff-only";

        # Diff the whole directory with meld in one shot
        dirdiff = "difftool --dir-diff --tool=meld";
        core = { editor = "vim"; };
        format = { pretty = "oneline"; };
        pull = { ff = "only"; };
        push = { default = "simple"; };
        color = { ui = "true"; };
        credential = { helper = "cache --timeout=1440"; };
        merge = { tool = "meld"; };
        mergetool = {
          meld = [
            ''cmd = meld "$LOCAL" "$MERGED" "$REMOTE" --output "$MERGED"''
          ];
        };
        difftool = {
          prompt = "false";
          meld = [ ''cmd = meld "$LOCAL" "$REMOTE" ''];
        };
      };
    };
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "line-numbers side-by-side";
    };
  };
}
