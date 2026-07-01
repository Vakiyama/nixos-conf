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

    wireplumber.extraConfig."51-disable-suspend" = {
      "wireplumber.profiles".main."hooks.node.suspend" = "disabled";
    };
  };

  security.rtkit.enable = true;
}
