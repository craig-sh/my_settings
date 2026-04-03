{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./common.nix
    ./common_stable.nix
    #./programs/aider.nix
    ./virtserver.nix
  ];

  home.file.".config/containers/storage.conf".text = ''
    [storage]
    driver = "overlay"
    graphRoot = "/mnt/k8sconfig/podman/craig"
  '';
}
