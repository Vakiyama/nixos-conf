{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
  ];

  # don't change xd
  system.stateVersion = "24.05";
}
