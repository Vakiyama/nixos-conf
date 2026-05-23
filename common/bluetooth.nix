{ ... }:
{
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Name = "Hello";
        ControllerMode = "dual";
        FastConnectable = "true";
        Disable = "Headset,Gateway";
      };
      Policy = {
        AutoEnable = "true";
      };
    };
  };
}
