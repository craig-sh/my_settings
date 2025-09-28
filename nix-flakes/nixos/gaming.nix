# Got this from https://github.com/HirschBerge/Public-dots/blob/main/nixos%2Fyoitsu%2Fconfigs%2Fgaming.nix#L5-L14

# Maybe we can move most of this to home manager?
{ pkgs, ...}:
{
  #enable Steam: https://linuxhint.com/how-to-instal-steam-on-nixos/
  programs.steam.enable = true;
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        pango
        libthai
        harfbuzz
      ];
    };
  };
  #programs.steam.gamescopeSession.enable = true;
  programs.gamescope = {
    enable = true;
    #capSysNice = true;
  };
  # Workaround for capsysnice from https://github.com/NixOS/nixpkgs/issues/351516#issuecomment-2607156591
 
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-cpp;
    extraRules = [
      {
        "name" = "gamescope";
        "nice" = -20;
      }
    ];
  };

  hardware.graphics = {
    enable32Bit = true;
    extraPackages = [ pkgs.gamescope-wsi ];
    extraPackages32 = [ pkgs.pkgsi686Linux.gamescope-wsi ];
  };


  # Manually renice process instead of capSysNice above because of issues with gamescope
  # See: https://discourse.nixos.org/t/unable-to-activate-gamescope-capsysnice-option/37843/12

  security.sudo.extraRules = [
    { users = [ "craig" ];
      runAs = "root";
      commands = [
        { command = "${pkgs.util-linux}/renice"; options = [ "NOPASSWD" ]; }
        #{ command = "renice"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

}
