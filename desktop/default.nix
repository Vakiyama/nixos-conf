{ ... }:
{
  imports = [
    ./nvidia.nix
    ./hardware-configuration.nix
  ];

  # don't change xd
  system.stateVersion = "24.05";
}
