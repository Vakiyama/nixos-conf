{ pkgs, ... }:
{
  services.udev.extraRules = ''
    SUBSYSTEM=="bluetooth", ATTR{address}=="30:03:c8:cb:f1:02", \
    RUN+="${pkgs.bluez}/bin/hciconfig %k down"
  '';
}

