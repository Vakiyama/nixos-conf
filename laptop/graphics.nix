
{ pkgs, ...}:

{
  hardware.graphics.extraPackages = with pkgs; [ intel-vaapi-driver intel-media-driver ];
}
