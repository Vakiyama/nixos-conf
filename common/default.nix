{ pkgs, config, ... }:
{
  imports = [
    ./hyprland.nix
    ./unfree.nix
    ./tpm.nix
    ./pipewire.nix
    ./virtualisation.nix
    ./network.nix
    ./keyboard.nix
    ./env.nix
    ./misc.nix
    ./notes.nix
    ./bluetooth.nix
    ./fish.nix
    ./steam.nix
  ];

  systemd.tmpfiles.rules = [
    "d /etc/nixos 0775 root nix"
  ];
  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [
    _1password-gui
    curl
    firefox
    git
    git-lfs
    gcc
    wget
    fzf
    tmux
    gnumake42
    vulkan-tools
    jq
    egl-wayland
    networkmanagerapplet
    wl-clipboard
    fd
    usbutils
    lazygit
    zip
    unzip
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
  users.users.Root = {
    isNormalUser = true;
    createHome = false;
    extraGroups = [ "wheel" "audio" "libvirtd" "qemu-libvirtd" "tss" "docker" "adbusers" "plugdev" "docker" ];
    shell = pkgs.bash;
    packages = with pkgs;[
      home-manager
    ];
  };



  services.dbus.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.blueman.enable = true;

<<<<<<< HEAD
  networking.firewall.trustedInterfaces = [ "p2p-wl+" ];
  networking.firewall.allowedTCPPorts = [ 7236 7250 ];
  networking.firewall.allowedUDPPorts = [ 7236 5353 ];
=======
  # dolphin emulator for wii
  services.udev.packages = [ pkgs.dolphin-emu ];
  boot.kernelModules = [
    "gcadapter_oc"
  ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.gcadapter-oc-kmod
  ];

  networking.firewall.allowedTCPPorts = [ 8081 ];
  networking.firewall.allowedUDPPorts = [ 8081 ];
>>>>>>> origin/main
  networking.firewall.enable = true;
}
