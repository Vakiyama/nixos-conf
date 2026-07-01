{ config, ... }:
{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;

      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
  boot.kernelParams = [
    "nvidia-drm.fbdev=1"
  ];


  services.xserver.videoDrivers = [ "nvidia" ];

  environment.sessionVariables = {
  GBM_BACKEND = "nvidia-drm";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  __GL_GSYNC_ALLOWED = "1";
  __GL_VRR_ALLOWED = "0";
};
}
