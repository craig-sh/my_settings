{ inputs, pkgs, ... }:
{

  #environment.systemPackages = [
  #  pkgs.wlroots_0_17
  #];
  nixpkgs.overlays = [
    ##  (final: prev: {
    ##    python3 = prev.python3.override {
    ##      packageOverrides = python-self: python-super: {
    ##        pywlroots = python-super.pywlroots.overrideAttrs (oldAttrs: {
    ##          src = prev.fetchPypi {
    ##            pname = "pywlroots";
    ##            version = "0.17.0";  # New version for all users
    ##            sha256 = "bf314bae5d7a9552225c44ab1e7bf7e4fafa869e";
    ##          };
    ##        });
    ##      };
    ##    };
    ##  })
    #(final: prev: {
    #  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    #    (
    #    python-final: python-prev: {
    #      pywlroots = python-prev.pywlroots.overridePythonAttrs (oldAttrs: {
    #         version = "0.17.0";  # New version for all users
    #         format = "setuptools";
    #         pname = "pywlroots";
    #         src = prev.fetchPypi {
    #           pname = "pywlroots";
    #           version = "0.17.0";  # New version for all users
    #           sha256 = "sha256-cssr4UBIwMvInM8bV4YwE6mXf9USSMMAzMcgAefEPbs=";
    #         };
    #      });
    #    }
    #    )
    #  ];
    #})

    #  #(final: prev: {
    #  #  #pywlroots = inputs.nixpkgs-unstable.legacyPackages."${pkgs.system}".pywlroots;
    #  #  python3 = prev.python3.override {
    #  #    packageOverrides = pfinal: pself: {
    #  #        pywlroots = inputs.nixpkgs-unstable.legacyPackages."${pkgs.system}".python311Packages.pywlroots;
    #  #    };
    #  #  };
    #  #})
    #  # Override full python3
    #  #(final: prev: {
    #  #  python3 = inputs.nixpkgs-unstable.legacyPackages."${pkgs.system}".python3;
    #  #})
    #  ########################
    #  #(final: prev: {
    #  #inputs.qtile-flake.overlays = inputs.qtile-flake.overlays.overrideAttrs (
    #  #_: {python3 = inputs.nixpkgs-unstable.legacyPackages."${pkgs.system}".python3;}
    #  #);
    #  #})
    #  #(final: prev: {
    #  #inputs.qtile-flake.overlays = inputs.qtile-flake.overlays.override
    #  #{python3 = inputs.nixpkgs-unstable.legacyPackages."${pkgs.system}".python3;};
    #  #})
    #  #(final: prev: {
    #  #inputs.qtile-flake.overlays = inputs.qtile-flake.overlays.override
    #  #  {pythonPackagesOverlays = prev.pythonPackagesOverlays ++ [
    #  #      (python-final: python-prev: {
    #  #        # Define your package overrides or additions here
    #  #        wlroots = python-final.callPackage ./my-package.nix {};
    #  #      })
    #  #  ];}
    #  #})
    inputs.qtile-flake.overlays.default
  ];
  services.xserver.windowManager.qtile = {
    enable = true;
    extraPackages =
      python3Packages: with python3Packages; [
        #qtile-extras
        pulsectl-asyncio
      ];
    configFile = "/home/craig/.config/qtile/config.py";
  };
  services.displayManager.sddm.enable = true;
  #services.displayManager.defaultSession = "qtile";
  services.picom = {
    enable = true;
  };
}
