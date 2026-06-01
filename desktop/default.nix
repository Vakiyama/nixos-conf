{ ... }:
{
  imports = [
    ./nvidia.nix
    ./hardware-configuration.nix
    ./llm.nix
    ./bluetooth.nix
  ];

  # don't change xd
  system.stateVersion = "24.05";
}
