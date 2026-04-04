{ ... }:

{
  imports = [
    ./common.nix
    #./programs/aider.nix
    #./programs/jellyfin.nix
  ];

  programs.zsh.loginShellInit = ''
    if [[ -n "$SSH_TTY" && -z "$TMUX" ]]; then
      if ! tmux has-session -t main 2>/dev/null; then
        tmux new-session -d -s main -n "config"
        tmux send-keys -t main:config "gonix && vim ." Enter
        tmux split-window -t main:config
        tmux send-keys -t main:config "gonix" Enter

        tmux new-window -t main -n "conrun"
        tmux send-keys -t main:conrun "machinectl shell conrun@.host"
        tmux split-window -t main:conrun
        tmux send-keys -t main:conrun "machinectl shell conrun@.host"

        tmux select-window -t main:config
      fi
      exec tmux attach-session -t main
    fi
  '';
}
