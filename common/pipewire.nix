{ ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  security.rtkit.enable = true;
services.pipewire.extraConfig.pipewire."90-stable" = {
  context.properties = {
    default.clock.rate = 48000;

    # more conservative than typical defaults
    default.clock.quantum = 4096;     # ~21ms @ 48k
    default.clock.min-quantum = 256;  # allow it to go lower if it can
    default.clock.max-quantum = 4096; # allow it to go much higher under load
  };
};
services.pipewire.extraConfig.pipewire-pulse."90-stable" = {
  stream.properties = {
    # bigger = more latency, fewer underruns
    pulse.min.req = "1024/48000";
    pulse.default.req = "2048/48000";
    pulse.max.req = "4096/48000";
  };
};


}
