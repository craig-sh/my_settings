{ pkgs, ... }:

{
  programs.zsh = {
    shellAliases = {
      kubectl = "sudo k3s kubectl";
    };
    sessionVariables = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };
  };
}
