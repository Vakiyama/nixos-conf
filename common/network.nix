{ ... }:
{

  networking.hostName = "Poison"; # Define your hostname.
  # Enable networking
  networking.networkmanager.enable = true;
  # networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
  environment.etc = {
    "resolv.conf".text = "nameserver 8.8.8.8\n";
  };
}
