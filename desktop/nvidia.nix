{ config, ... }:
{
  hardware = {
    graphics = {
      enable = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;

      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

}
