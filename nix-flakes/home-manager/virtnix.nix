{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.quadlet-nix.homeManagerModules.quadlet
    ./common.nix
    ./common_stable.nix
    #./programs/aider.nix
    ./virtserver.nix
  ];

  home.file.".zlogin".text = ''
    if [[ -n "$SSH_TTY" && -z "$TMUX" ]]; then
      if ! tmux has-session -t main 2>/dev/null; then
        tmux new-session -d -s main -n "config"
        tmux send-keys -t main:config "gonix && vim ." Enter
        tmux split-window -t main:config
        tmux send-keys -t main:config "gonix" Enter

        tmux new-window -t main -n "homelab"
        tmux send-keys -t main:homelab "cd /home/craig/homelab/helm/homelab && vim ." Enter
        tmux split-window -t main:homelab
        tmux send-keys -t main:homelab "cd /home/craig/homelab/helm/homelab" Enter

        tmux new-window -t main -n "conrun"
        tmux send-keys -t main:conrun "machinectl shell conrun@.host"
        tmux split-window -t main:conrun
        tmux send-keys -t main:conrun "machinectl shell conrun@.host"

        tmux select-window -t main:config
      fi
      exec tmux attach-session -t main
    fi
  '';

  home.file.".config/containers/storage.conf".text = ''
    [storage]
    driver = "overlay"
    graphRoot = "/mnt/k8sconfig/podman/craig"
  '';
}
