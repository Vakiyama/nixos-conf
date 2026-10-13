# NixOS-WSL host for the work machine. Deliberately does NOT import ../common:
# hyprland, pipewire, bluetooth, tpm, systemd-boot and the broadcom/gcadapter
# kernel modules all assume real hardware and break (or make no sense) in WSL.
{ pkgs, ... }:
{
  wsl.enable = true;
  wsl.defaultUser = "Root"; # same user as the desktop, so the HM flake just works
  wsl.interop.includePath = true; # clip.exe / powershell.exe for nvim clipboard

  networking.hostName = "work-wsl";
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nixpkgs.config.allowUnfree = true;

  # Lets Mason LSPs, blink.cmp's prebuilt binary, etc. run on NixOS.
  programs.nix-ld.enable = true;

  programs.fish.enable = true;
  users.users.Root = {
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" ];
  };

  # Only what's needed to clone the dotfiles and run home-manager;
  # everything else comes from the HM `wsl` profile.
  environment.systemPackages = with pkgs; [ git curl home-manager ];

  # Docker Desktop's WSL integration is usually what work wants; if you'd
  # rather run docker inside the distro instead, uncomment:
  # virtualisation.docker.enable = true;

  system.stateVersion = "25.05"; # set once at install, then don't change
}
