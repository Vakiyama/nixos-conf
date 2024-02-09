# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

with pkgs;
let 
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
  # RStudio-with-my-packages = rstudioWrapper.override{ packages = with rPackages; [ mosaic ]; };
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
     "electron-25.9.0"
     "electron-19.1.9"
  ];

  programs.bash.shellAliases = {
    rm = "rip";
    vi = "nvim";
    ls = "exa --icons -F -H --group-directories-first --git -1";
    lt = "exa --tree --level=2 --long --icons --git";
  };

  imports = [ ./hardware-configuration.nix ];

  programs.neovim.enable = true;
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;  # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true;  # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  # Enable dconf (System Management Tool)

  # Add user to libvirtd group

  # Install necessary packages

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

    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
        modesetting.enable = true;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    hardware.bluetooth = {
        enable = true;
        settings = {
          General = {
            Name = "Hello";
            ControllerMode = "dual";
            FastConnectable = "true";
            Experimental = "true";
          };
          Policy = {
            AutoEnable = "true";
          };
        };
    };

    systemd.timers."backup-notes" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "backup-notes.service";
      };
    };

    systemd.services."backup-notes" = {
      script = ''
        # Navigate to the notes directory
        cd /home/Root/vaults/notes 
        # Fetch the latest changes from the remote repository
        /home/Root/.nix-profile/bin/git fetch origin
        

        # Pull the latest changes
        /home/Root/.nix-profile/bin/git pull origin main

        # Add all new and changed files to the commit
        /home/Root/.nix-profile/bin/git  add .

        # Commit the changes with the current date as the message
        DATE=$(date +'%Y-%m-%d %H:%M:%S')
        /home/Root/.nix-profile/bin/git commit -m "auto backup: $DATE"

        # Push the commit to the remote repository
        /home/Root/.nix-profile/bin/git push origin main
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "Root";
        Group = "users";
        SuccessExitStatus="0 1 7";
      };
    };

    sound.enable = true;
    hardware.pulseaudio.enable = true;
    services.mysql = {
        enable = true;
        package = pkgs.mysql80;
    };
    services.postgresql = {
        enable = true;
        ensureDatabases = [ "dmfnew5" ];
        enableTCPIP = true;
        package = pkgs.postgresql_14;
        authentication = pkgs.lib.mkOverride 10 ''
          #type database  DBuser  auth-method
          local all all trust
          host dmfnew5 postgres all trust
        '';
# this does nothing
#       initialScript = pkgs.writeText "backend-initScript" ''
#          CREATE ROLE fdc WITH LOGIN PASSWORD 'test' CREATEDB;
#          CREATE DATABASE dmfnew3;
#          GRANT ALL PRIVILEGES ON DATABASE dmfnew3 TO fdc;
#        '';
        #ba.conf entry for host "::1", user "dmfuser", database "fdcdevelopment", no encryption\n')
    };
    #psql: error: connection to server at "localhost" (::1), port 5432 failed: FATAL:  no pg_hba.conf entry for host "::1", user "postgres", database "fdcdevelopment", no encryption


    users.users.Root = {
        isNormalUser = true;
        extraGroups = ["wheel" "audio" "libvirtd" "tss" "docker" "adbusers" "plugdev"];
        packages = with pkgs;[
            home-manager

            google-chrome
            discord
            spotify
            neofetch
            i3-rounded
            feh

            gnome.adwaita-icon-theme
            obsidian
            slack
            docker # maybe should be in flakes?
            ripgrep
            simplescreenrecorder
            zlib
            starship
            yq-go
            pciutils
            tridactyl-native
            steam
            mysql-workbench
            gnome.gnome-keyring
            shutter
            lutris
            etcher
            ngrok
            unstable.r2modman
            ocaml
            opam
            dune_3
            ocamlPackages.merlin
            git-graph

            unstable.ticktick
            htop-vim
            bottom
            prettierd

            eza # better ls (exa)
            rm-improved # safer rm (rip)
            kdenlive
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
            yarn
            bun
            cargo
            wget
            kitty
            fzf
            tmux
            linuxPackages.nvidia_x11
            gnumake42
            vulkan-tools
    ];



# Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.blueman.enable = true;
    services.picom.enable = true;
    services.gnome3.gnome-keyring.enable = true;
    services.xserver = {
        enable = true;

        libinput.mouse = {
            accelProfile = "flat";
            middleEmulation = false;
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
                #dmenu
                rofi
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
    system.stateVersion = "23.11"; # Did you read the comment?
}
