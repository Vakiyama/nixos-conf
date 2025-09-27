{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    hyprpaper
    wl-clipboard
    grim
    slurp
    imagemagick
  ];


  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland;
  };
}
