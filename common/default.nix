{ pkgs, ... }:
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
    exa
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

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = true;
}
