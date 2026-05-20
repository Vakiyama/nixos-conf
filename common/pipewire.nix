{ ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
    wireplumber.extraConfig = {
      "51-disable-hfp" = {
        "monitor.bluez.properties" = {
          "bluez5.headset-roles" = [ ];
        };
      };
    };
  };

  security.rtkit.enable = true;

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    context.properties = {
      default.clock.rate = 48000;
      default.clock.quantum = 32;
      default.clock.min-quantum = 32;
      default.clock.max-quantum = 32;
    };
  };
}
