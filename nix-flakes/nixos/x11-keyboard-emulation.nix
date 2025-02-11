{ pkgs, ... }:

let
    myCustomLayout = pkgs.writeText "xkb-layout" ''
      ! Unmap capslock
      clear Lock
      keycode 66 = Mode_switch

      !keycode 66 = Hyper_L
      !! Leave mod4 as windows key _only_
      !remove mod4 = Hyper_L
      !! Set mod3 to capslock
      !add mod3 = Hyper_L

      keysym h = h H Left
      keysym l = l L Right
      keysym k = k K Up
      keysym j = j J Down

      keysym a = a A End
      keysym b = b B Home
      keysym d = d D Next
      keysym u = u U Prior

      !! Comment out until qtile bug is fixed
      !! keysym t = t T XF86AudioRaiseVolume
      !! keysym s = s S XF86AudioLowerVolume
      !! keysym w = w W XF86AudioPlay
      !! keysym q = q Q XF86AudioPrev
      !! keysym e = e E XF86AudioNext

      !! keysym grave = Escape asciitilde grave
      keysym BackSpace = BackSpace BackSpace Delete
    '';
in {
  services.xserver.displayManager.sessionCommands = "${pkgs.xorg.xmodmap}/bin/xmodmap ${myCustomLayout}";
}
