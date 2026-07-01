{ ... }:
{
  services.resolved = {
    enable = true;
    dnsovertls = "true";
    domains = [ "~." ];
    fallbackDns = [ ];
  };
  networking.networkmanager.dns = "systemd-resolved";
  networking.hostName = "Poison"; # Define your hostname.
  # Enable networking
  networking.networkmanager.enable = true;
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];
  # environment.etc = {
  #   "resolv.conf".text = "nameserver 8.8.8.8\n";
  # };
}
