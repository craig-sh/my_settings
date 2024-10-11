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
}
