{
  description = "Craig's NixOS Flake";

  # This is the standard format for flake.nix.
  # `inputs` are the dependencies of the flake,
  # and `outputs` function will return all the build results of the flake.
  # Each item in `inputs` will be passed as a parameter to
  # the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs.
    # The most widely used is `github:owner/name/reference`,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos-unstable branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.
    qtile-flake = {
      #url = "github:qtile/qtile/eed1e03c7fe22780cfb93689b5a58bdbc23deee0";
      url = "github:qtile/qtile";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    mysecrets = {
      url = "git+file:/home/craig/private/secrets";
      flake = false;
    };
    catppuccin.url = "github:catppuccin/nix";
  };

  # `outputs` are all the build result of the flake.
  #
  # A flake can have many use cases and different types of outputs.
  #
  # parameters in function `outputs` are defined in `inputs` and
  # can be referenced by their names. However, `self` is an exception,
  # this special parameter points to the `outputs` itself(self-reference)
  #
  # The `@` syntax here is used to alias the attribute set of the
  # inputs's parameter, making it convenient to use inside the function.
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      home-manager-unstable,
      nixpkgs-unstable,
      sops-nix,
      nix-flatpak,
      quadlet-nix,
      catppuccin,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      username = "craig";
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      nixosConfigurations = {
        # By default, NixOS will try to refer the nixosConfiguration with
        # its hostname, so the system named `virtnix` will use this one.
        # However, the configuration name can also be specified using:
        #   sudo nixos-rebuild switch --flake /path/to/flakes/directory#<name>
        #
        # The `nixpkgs.lib.nixosSystem` function is used to build this
        # configuration, the following attribute set is its parameter.
        #
        # Run the following command in the flake's directory to
        # deploy this configuration on any NixOS system:
        #   sudo nixos-rebuild switch --flake .#nixos-test
        "virtnix" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            sops-nix.nixosModules.sops
            ./nixos/services/sops.nix
            ./nixos/hosts/virt/hardware-configuration.nix
            ./nixos/hosts/virt/base-configuration.nix
            ./nixos/hosts/virt/k3s-controller.nix
            ./nixos/hosts/virt/tailscale.nix
          ];
          specialArgs = { inherit inputs username; };
        };
        "virtnix2" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            sops-nix.nixosModules.sops
            ./nixos/services/sops.nix
            ./nixos/hosts/virt/hardware-configuration.nix
            ./nixos/hosts/virt/base-configuration.nix
            ./nixos/hosts/virt/k3s-agent.nix
          ];
          specialArgs = { inherit inputs username; };
        };
        "beelink" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            sops-nix.nixosModules.sops
            quadlet-nix.nixosModules.quadlet
            ./nixos/services/sops.nix
            ./nixos/hosts/beelink/hardware-configuration.nix
            ./nixos/hosts/beelink/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.craig.imports = [
                ./home-manager/common.nix
                ./home-manager/beelink.nix
              ];
              home-manager.users.conrun.imports = [ ./home-manager/conrun.nix ];
              home-manager.extraSpecialArgs = { inherit inputs outputs username; };
            }
            #./nixos/hosts/virt/k3s-agent.nix
          ];
          specialArgs = { inherit inputs username; };
        };
        "hypernix" = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            sops-nix.nixosModules.sops
            nix-flatpak.nixosModules.nix-flatpak
            ./nixos/services/sops.nix
            ./nixos/hosts/hypernix/hardware-configuration.nix
            ./nixos/hosts/hypernix/configuration.nix
          ];
          specialArgs = { inherit inputs username; };
        };
        "carbonnix" = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            sops-nix.nixosModules.sops
            nix-flatpak.nixosModules.nix-flatpak
            ./nixos/services/sops.nix
            ./nixos/hosts/carbonnix/hardware-configuration.nix
            ./nixos/hosts/carbonnix/configuration.nix
          ];
          specialArgs = { inherit inputs username; };
        };
        # The Nix module system can modularize configuration,
        # improving the maintainability of configuration.
        #
        # Each parameter in the `modules` is a Nix Module, and
        # there is a partial introduction to it in the nixpkgs manual:
        #    <https://nixos.org/manual/nixpkgs/unstable/#module-system-introduction>
        # It is said to be partial because the documentation is not
        # complete, only some simple introductions.
        # such is the current state of Nix documentation...
        #
        # A Nix Module can be an attribute set, or a function that
        # returns an attribute set. By default, if a Nix Module is a
        # function, this function have the following default parameters:
        #
        #  lib:     the nixpkgs function library, which provides many
        #             useful functions for operating Nix expressions:
        #             https://nixos.org/manual/nixpkgs/stable/#id-1.4
        #  config:  all config options of the current flake, very useful
        #  options: all options defined in all NixOS Modules
        #             in the current flake
        #  pkgs:   a collection of all packages defined in nixpkgs,
        #            plus a set of functions related to packaging.
        #            you can assume its default value is
        #            `nixpkgs.legacyPackages."${system}"` for now.
        #            can be customed by `nixpkgs.pkgs` option
        #  modulesPath: the default path of nixpkgs's modules folder,
        #               used to import some extra modules from nixpkgs.
        #               this parameter is rarely used,
        #               you can ignore it for now.
        #
        # The default parameters mentioned above are automatically
        # generated by Nixpkgs.
        # However, if you need to pass other non-default parameters
        # to the submodules,
        # you'll have to manually configure these parameters using
        # `specialArgs`.
        # you must use `specialArgs` by uncomment the following line:
        #
        # specialArgs = {...};  # pass custom arguments into all sub module.
      };
      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        "craig@virtnix" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            inputs.sops-nix.homeManagerModules.sops
            ./home-manager/common.nix
            ./home-manager/common_stable.nix
            ./home-manager/virtserver.nix
          ];
        };
        "craig@virtnix2" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            inputs.sops-nix.homeManagerModules.sops
            ./home-manager/common.nix
            ./home-manager/virtserver.nix
          ];
        };
        "craig@hyperarch" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            inputs.sops-nix.homeManagerModules.sops
            ./home-manager/common.nix
            ./home-manager/programs/neovim_git.nix
          ];
        };
        "craig@carbonnix" = home-manager-unstable.lib.homeManagerConfiguration {
          pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs username; };
          modules = [
            inputs.sops-nix.homeManagerModules.sops
            ./home-manager/carbonnix.nix
            catppuccin.homeModules.catppuccin
          ];
        };
        "craig@hypernix" = home-manager-unstable.lib.homeManagerConfiguration {
          pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs username; };
          modules = [
            inputs.sops-nix.homeManagerModules.sops
            ./home-manager/hypernix.nix
            catppuccin.homeModules.catppuccin
          ];
        };
      };
    };
}
