# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, callPackage, ... }:

with pkgs;
let 
    unstable = import <unstable> { config.allowUnfree = true; };
    RStudio-with-my-packages = rstudioWrapper.override{ packages = with rPackages; [ mosaic ]; };
in
{
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    fonts.fonts = with pkgs; [ 
        (nerdfonts.override { fonts = ["FiraCode" "DroidSansMono" ];}) 
    ];

    #/home/Root/projects/custom-nixpkgs/super-productivity
    nixpkgs.config = { 
        allowUnfree = true;
    #    packageOverrides = pkgs: {
    #        mySuperProductivity = import ./super-productivity { inherit pkgs; };
    #    };
    };

    nixpkgs.config.permittedInsecurePackages = [
       "electron-24.8.6"
    ];

    programs.bash.shellAliases = {
        vi = "nvim";
    };

    imports = [ ./hardware-configuration.nix ./passthrough.nix ];

    specialisation."VFIO".configuration = {
        system.nixos.tags = [ "with-vfio" ];
        vfio.enable = true;
    };
    programs.neovim.enable = true;
    security.tpm2.enable = true;
    security.tpm2.pkcs11.enable = true;  # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
    security.tpm2.tctiEnvironment.enable = true;  # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
    # Enable dconf (System Management Tool)

  # Add user to libvirtd group

  # Install necessary packages

  # Manage the virtualisation services
  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true; # disable when working with android
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
  services.udev.extraRules = ''
                            # Rules for Oryx web flashing and live training
                            KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
                            KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

                            # Legacy rules for live training over webusb (Not needed for firmware v21+)
                            # Rule for all ZSA keyboards    
                            SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
                            # Rule for the Moonlander
                            SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
                            # Rule for the Ergodox EZ
                            SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
                            # Rule for the Planck EZ
                            SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

                            # Wally Flashing rules for the Ergodox EZ
                            ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
                            ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
                            SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
                            KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

                            # Wally Flashing rules for the Moonlander and Planck EZ
                            SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11",     MODE:="0666",     SYMLINK+="stm32_dfu"
                        '';
  users.groups.plugdev = {};

# Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "Poison"; # Define your hostname.
# Enable networking
        networking.networkmanager.enable = true;

# Set your time zone.
    time.timeZone = "America/Vancouver";

# Select internationalisation properties.
    i18n.defaultLocale = "en_CA.UTF-8";

    hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
    };

    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia = {
        modesetting.enable = true;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
    };

    sound.enable = true;
    hardware.pulseaudio.enable = true;


    users.users.Root = {
        isNormalUser = true;
        extraGroups = ["wheel" "audio" "libvirtd" "tss" "docker" "adbusers" "plugdev"];
        packages = with pkgs;[
            home-manager

            opera
            google-chrome
            discord
            spotify
            neofetch
            i3-rounded
            feh

            # all vm related
            virt-manager
            virt-viewer
            spice spice-gtk
            spice-protocol
            win-virtio
            win-spice
            scream # low-latency audio for win11 VM

            gnome.adwaita-icon-theme
            obsidian
            slack
            docker # maybe should be in flakes?
            ripgrep
            simplescreenrecorder
            RStudio-with-my-packages
            zlib
            starship
            yq-go

            unstable.ticktick
            htop-vim
            bottom
        ];
    };
    programs.dconf.enable = true;
    programs.adb.enable = true;

# List packages installed in system profile. To search, run:
# $ nix search wget
    environment.systemPackages = with pkgs; [
        _1password-gui
            firefox
            git
            gcc
            nodejs_20
            bun
            cargo
            wget
            kitty
            fzf
            tmux
            linuxPackages.nvidia_x11
    ];



# Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.blueman.enable = true;
    services.picom.enable = true;

    services.xserver = {
        enable = true;

        libinput.mouse = {
            accelProfile = "flat";
        };
        desktopManager = {
            xterm.enable = false;
            xfce = {
                enable = true;
                noDesktop = true;
                enableXfwm = false;
            };
        };

        displayManager = {
            defaultSession = "xfce+i3";
        };

        windowManager.i3 = {
            enable = true;
            package = pkgs.i3-rounded;
            extraPackages = with pkgs; [
                dmenu
                i3status
                i3lock
            ];
        };
    };

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
  networking.firewall.enable = false;

# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It‘s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "unstable"; # Did you read the comment?
}