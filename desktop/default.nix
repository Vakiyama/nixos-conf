{ ... }:
{
  imports = [
    ./nvidia.nix
    ./hardware-configuration.nix
    ./llm.nix
    ./bluetooth.nix
  ];

  services.tailscale.enable = true;

  # don't change xd
  system.stateVersion = "24.05";
}
