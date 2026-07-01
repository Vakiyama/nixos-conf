{ config, lib, ... }:
{
  boot.blacklistedKernelModules = [ "bcma" ];


  nixpkgs.config.allowInsecurePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "broadcom-sta" ];

  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  services.spice-vdagentd.enable = true;
  users.groups.plugdev = { };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";

  hardware.steam-hardware.enable = true;
  programs.java.enable = true;


  programs.dconf.enable = true;
  virtualisation.docker.enable = true;
}
