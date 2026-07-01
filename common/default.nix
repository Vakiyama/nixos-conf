{ pkgs, pkgs-unstable, config, lib, ... }:
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
  ];

  environment.systemPackages = with pkgs; [
    pkgs-unstable._1password-gui
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

  nix.settings.auto-optimise-store = true;

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
  services.gnome.gnome-keyring.enable = true;        # provides org.freedesktop.secrets, activatable
  security.pam.services.login.enableGnomeKeyring = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.blueman.enable = true;

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
  networking.firewall.enable = true;
}
