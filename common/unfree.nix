{ ... }:
{
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    nvidia.acceptLicense = true;
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
    "electron-19.1.9"
    "electron-33.4.11"
    "qtwebkit-5.212.0-alpha4"
  ];
}
