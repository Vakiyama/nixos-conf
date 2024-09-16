# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

with pkgs;
let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
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
    "qtwebkit-5.212.0-alpha4" # dmf backend flake
  ];

  programs.bash.shellAliases = {
    rm = "rip";
    vi = "nvim";
    ls = "exa --icons -F -H --group-directories-first --git -1";
    lt = "exa --tree --level=2 --long --icons --git";
  };

  # Blacklist the bcma module
  boot.blacklistedKernelModules = [ "bcma" ];
  # hardware.firmware = [ pkgs.linux-firmware ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  imports = [ ./hardware-configuration.nix ];

  programs.neovim.enable = true;
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  # Enable dconf (System Management Tool)

  # Add user to libvirtd group

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };

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
  users.groups.plugdev = { };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Poison"; # Define your hostname.
  # Enable networking
  networking.networkmanager.enable = true;
  # networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
  environment.etc = {
    "resolv.conf".text = "nameserver 8.8.8.8\n";
  };

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
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
      SuccessExitStatus = "0 1 7";
    };
  };

  sound.enable = true;
  # hardware.pulseaudio.enable = true;
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = true;

  #services.pipewire = {
  #  enable = true;
  #  alsa.enable = true;
  #  alsa.support32Bit = true;
  #  pulse.enable = true;
  #  # If you want to use JACK applications, uncomment this
  #  #jack.enable = true;
  #};

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    context.properties = {
      default.clock.rate = 48000;
      default.clock.quantum = 32;
      default.clock.min-quantum = 32;
      default.clock.max-quantum = 32;
    };
  };

  # services.mysql = {
  #   enable = true;
  #   package = pkgs.mysql80;
  # };

  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = [ "dmfnew5" ];
  #   enableTCPIP = true;
  #   package = pkgs.postgresql_14;
  #   authentication = pkgs.lib.mkOverride 10 ''
  #     #type database  DBuser  auth-method
  #     local all all trust
  #     host dmfnew5 postgres all trust
  #   '';
  #   # this does nothing
  #   #       initialScript = pkgs.writeText "backend-initScript" ''
  #   #          CREATE ROLE fdc WITH LOGIN PASSWORD 'test' CREATEDB;
  #   #          CREATE DATABASE dmfnew3;
  #   #          GRANT ALL PRIVILEGES ON DATABASE dmfnew3 TO fdc;
  #   #        '';
  #   #ba.conf entry for host "::1", user "dmfuser", database "fdcdevelopment", no encryption\n')
  # };


  users.users.Root = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "libvirtd" "tss" "docker" "adbusers" "plugdev" "docker" ];
    shell = pkgs.bash;
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
      ngrok
      unstable.r2modman
      ocaml
      opam
      dune_3
      ocamlPackages.merlin
      git-graph

      htop-vim
      prettierd

      eza # better ls (exa)
      rm-improved # safer rm (rip)
      unstable.kdenlive
      obs-studio
      gleam
      erlang
      rebar3
      pgmodeler
      pulseeffects-legacy

      prismlauncher
      wine64
      wineWow64Packages.full
      samba

      ytfzf
      ueberzugpp
      mpv
      python3
      apacheHttpd

      luajitPackages.luarocks
      unzip
    ];
  };
  programs.dconf.enable = true;
  programs.adb.enable = true;
  virtualisation.docker.enable = true;

  services.httpd.enable = true;
  services.httpd.adminAddr = "webmaster@example.org";





  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    _1password-gui
    curl
    firefox
    git
    git-lfs
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
    jq
    (lutris.override {
      extraLibraries = pkgs: [
        # List library dependencies here
      ];
    })
    grim
    slurp
    imagemagick
    egl-wayland
    fuzzel
    mako
    networkmanagerapplet
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # services.dbus.enable = true;
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  # };


  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    CLUTTER_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    GTK_USE_PORTAL = "1";
    NIXOS_XDG_OPEN_USE_PORTAL = "1";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    ENABLE_VKBASALT = "1";
  };


  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.blueman.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

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
  system.stateVersion = "24.05"; # Did you read the comment?
}
