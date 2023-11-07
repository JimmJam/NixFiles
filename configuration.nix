{ config, pkgs, options, lib, ... }: 
let
  # Import home manager now, so it can work on new installs
  home-manager = fetchTarball 
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  commonKernelParams = [
    "modprobe.blacklist=pcspkr"
    "amd_iommu=on"
    "iommu=pt"
    "transparent_hugepage=never"
    "irqpoll"
    "pci=routeirq"
    "kvm_amd"
    "nested=1"
    "allow_unsafe_interrupts=1"
    "kvm"
    "ignore_msrs=1"
    "pcie_acs_override=downstream,multifunction"
    "pci=noats"
  ];
in

{
  # Import other files from the NixOS config folder
  imports = [ 
    ./hardware-configuration.nix ./jimbo.nix (import "${home-manager}/nixos")
  ];

  # Allow unfree packages and accept packages from the Nix User Repos
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "electron-24.8.6" ];
    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball 
        "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
  };

  # Allow unfree firmware for AMD, Bluetooth, etc
  hardware.enableAllFirmware = true;

  # Allow flakes (I have no clue how they work yet)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Change to a more optimized kernel and choose to boot with Nvidia drivers if available
  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    extraModulePackages = with config.boot.kernelPackages; [ nvidiaPackages.beta ]; 
    # .stable isn't new enough to fix my weird sway issues yet
    kernelParams = commonKernelParams ++ [ "vfio-pci.ids=10de:13c2,10de:0fbb" ];
    initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" 
      "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  };
  services.xserver.videoDrivers = ["nvidia"];

  # Add an extra kernel entry to boot from the secondary NVIDIA GPU
  specialisation = {
    gputwo.configuration = {
      boot.kernelParams = commonKernelParams ++ [ "vfio-pci.ids=10de:2504,10de:228e" ];
    };
  };

  # Enable the proprietary NVIDIA drivers
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Use the GRUB as the bootloader
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
       efiSupport = true;
       useOSProber = true;
       device = "nodev";
       theme = "${pkgs.sleek-grub-theme.override { withStyle = "dark"; withBanner = "Grub on NixOS"; }}";
    };
  };

  # Define all extra drives
  fileSystems = {
    "/etc/libvirt" = {
      device = "/dev/disk/by-label/Qemu";
      fsType = "auto";
      options = ["nosuid,nodev,nofail"] ;
    };
    "/mnt/Linux1" = {
      device = "/dev/disk/by-label/Linux1";
      fsType = "auto";
      options = ["nosuid,nodev,nofail,x-gvfs-show"];
    };
    "/mnt/Linux2" = {
      device = "/dev/disk/by-label/Linux2";
      fsType = "auto";
      options = ["nosuid,nodev,nofail,x-gvfs-show"];
    };                                      
    "/mnt/Windows1" = {
      device = "/dev/disk/by-label/Windows1";
      fsType = "auto";
      options = ["nosuid,nodev,nofail,noauto"];
    };                                      
    "/mnt/Windows2" = {
      device = "/dev/disk/by-label/Windows2";
      fsType = "auto";
      options = ["nosuid,nodev,nofail,noauto"];
    };
    "/home/jimbo/JimboSMB" = {
      device = "//192.168.1.17/Files";
      fsType = "cifs";
      options = ["nofail,user=jimbo,password=sillypasswd23,uid=1000,gid=100"];
    };                                    
    "/home/jimbo/SenecaMount" = {
      device = "//mydrive.senecacollege.ca/courses/";
      fsType = "cifs";
      options = ["noauto,username=jhampton1,workgroup=seneds.senecacollege.ca,uid=1000,gid=100"];
    };
  };

  # Create the sudoers file
  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
        { command = "${pkgs.systemd}/bin/reboot"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.systemd}/bin/shutdown"; options = [ "NOPASSWD" ]; }
      ];
      groups = [ "wheel" ];
    }];
  };

  # Define a user account.
  users.users.jimbo = {
    isNormalUser = true;
    initialHashedPassword = "$6$gYpE.pG/zPXgin06$2kydjDfd0K62Dhf9P0PFvJhRNz6xIC/bHYaf/XYqyKcLyZNzPQpy8uy9tCRcSYlj1wwBhzVtTRyItwajOHCEj0";
    extraGroups = [ "wheel" "audio" "video" "libvirtd" ];
    uid = 1000;
    shell = pkgs.zsh;
  };

  # Installed programs to the system profile.
  environment.systemPackages = with pkgs; [
    # Essential system tools
    cifs-utils ntfs3g microcodeAmd git

    # Printer drivers
    hplipWithPlugin

    # Virtual machines
    virtiofsd virt-manager swtpm nftables 
    dnsmasq spice-vdagent looking-glass-client

    # Cockpit machines
    pkgs.nur.repos.dukzcry.cockpit-machines
    pkgs.nur.repos.dukzcry.libvirt-dbus
  ];

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Enable Steam hardware and gamemode
  hardware.steam-hardware.enable = true;
  programs.gamemode.enable = true;

  # Enable ZSH
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "agnoster"; # Main PC
      #theme = "risto"; # Secondary/VM
    };
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    shellAliases = {
      nixswitch = "sudo nixos-rebuild switch";
      nixclean = "sudo nix-store --gc; nix-collect-garbage -d";
      nixcfg = "nvim /etc/nixos/configuration.nix /etc/nixos/hardware-configuration.nix";
      nixdate = "sudo nix-channel --update; sudo nixos-rebuild switch --upgrade";
      nixfix = "echo 'https://nixos.org/channels/nixos-unstable nixos' | sudo tee /root/.nix-channels";
    };
  };

  # Define timezone and networking settings
  time.timeZone = "America/New_York";
  networking = {
    hostName = "JimNixPC";
    dhcpcd.enable = true;
    wireless.iwd.enable = true;
    nftables.enable = true;
    firewall.enable = false;
  };

  # Enable Bluetooth and lingering for Bluetooth audio
  hardware.bluetooth = {
    enable = true;
    settings = {
      General.Experimental = "true";
      Policy = {
        AutoEnable = "true";
      };
    };
  };
  services.blueman.enable = true;
  systemd.tmpfiles.rules = [ 
    "f /var/lib/systemd/linger/jimbo"
    "f /dev/shm/looking-glass 0660 jimbo libvirtd -"
  ];

  # Create a custom udev rule to make my PDP controller work
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="0e6f", ATTRS{idProduct}=="0184", MODE="0660", TAG+="uaccess"
  '';

  # Enable audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  # Fonts
  fonts.packages = with pkgs; [
    liberation_ttf twitter-color-emoji ubuntu_font_family
    noto-fonts noto-fonts-cjk (nerdfonts.override { fonts = [ "UbuntuMono" ]; })
  ];

  # Define locate program
  services.locate = {
    enable = true;
    package = pkgs.mlocate;
    localuser = null;
  };

  # Enable Dconf and some portals
  services.dbus.enable = true;
  programs.dconf.enable = true;
  security.pam.services.swaylock = {};

  # Select default apps
  xdg.mime.defaultApplications = {
    "inode/directory" = "pcmanfm-qt.desktop";
    "text/plain" = "nvim.desktop";
    "image/png" = "imv.desktop";
    "image/jpeg" = "imv.desktop";
  };

  # Configure greetd for remote login
  services.greetd = {
    enable = true;
    restart = true;
    settings = rec {
      initial_session = {
        command = "/home/jimbo/.config/sway/start.sh";
        user = "jimbo";
      };
      default_session = initial_session;
    };
  };
  systemd.services.greetd.wantedBy = lib.mkForce [];

  # QT theming
  qt.enable = true;
  qt.platformTheme = "gtk2";

  # Enable CUPS for printing
  services.printing.enable = true;

  # Enable virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  # Enable Cockpit and SSH
  services.cockpit.enable = true;
  services.openssh.enable = true;

  # Enable Polkit for authentication
  security.polkit.enable = true;

  # Package overlays/patches
  nixpkgs.overlays = [
    (final: prev: {
      wlroots_0_16 = prev.wlroots_0_16.overrideAttrs (o: {
        patches = (o.patches or [ ]) ++ [
          ./patches/nvidia.patch ./patches/dmabuf-capture-example.patch
        ];
      });
    })
    (self: super: {
      mpv = super.mpv.override {
        scripts = [ self.mpvScripts.mpris ];
      };
    })
  ];

  # Determine the release version and allow auto-upgrades
  system.stateVersion = "unstable";
  system.autoUpgrade.enable = true;
}
