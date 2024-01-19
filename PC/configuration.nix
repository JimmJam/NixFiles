{ config, pkgs, options, lib, ... }: 
let
  # Import home manager, set common boot paramaters
  homeManager = fetchTarball 
    "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
  commonKernelParams = [
    # VM/GPU passthrough
    "amd_iommu=on"
    "iommu=pt"
    "nested=1"

    # Force GPUs into separate IOMMU groups
    "pcie_acs_override=downstream,multifunction"
    "pci=routeirq"
    "pci=noats"
    "allow_unsafe_interrupts=1"
    "ignore_msrs=1"

    # VM gaming performance
    "transparent_hugepage=never"
  ];
  nvidiaDriver = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
in

{
  # Import other nix files and firmware
  imports = [
    ./hardware-configuration.nix
    ./jimbo.nix
    "${homeManager}/nixos"
    #"${builtins.fetchTarball 
    #  { url = "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz"; }}/pine64/pinebook-pro"
  ];

  # Allow unfree packages and accept packages from the Nix User Repos
  nixpkgs = {
    config = {
      allowUnfree = true;
      #allowUnsupportedSystem = true;
      packageOverrides = pkgs: {
        unstable = import (builtins.fetchTarball 
          "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
          inherit pkgs;
          config.allowUnfree = true;
          overlays = [
            (final: prev: {
              wlroots_0_16 = prev.wlroots_0_16.overrideAttrs (o: {
                patches = (o.patches or [ ]) ++ [ 
                  (final.fetchpatch {
                    url = "https://git.jimbosfiles.duckdns.org/jimbo/NixOS-Files/raw/branch/main/Patches/nvidia.patch";
                    sha256 = "cpOzc3Y1a5F6UscgijBZJ0CXkceaF9t7aWQVLF76/1A=";
                  })
                  (final.fetchpatch {
                    url = "https://git.jimbosfiles.duckdns.org/jimbo/NixOS-Files/raw/branch/main/Patches/dmabuf-capture-example.patch";
                    sha256 = "PIO9EiwJZQsVp07YkfRsLu978AX2sdlg2LbRvldIuzc=";
                  })
                  (final.fetchpatch {
                    url = "https://git.jimbosfiles.duckdns.org/jimbo/NixOS-Files/raw/branch/main/Patches/screenshare.patch";
                    sha256 = "azvSsmGHR1uJe0k2hnaP6RCXfQnatpbGTMpDy9EPAr0=";
                  })
                ];
              });
            })
          ];
        };
      };
    };

    # Package overlays/patches
    overlays = [
      # MPV scripts
      (self: super: {
        mpv = super.mpv.override {
          scripts = with self.mpvScripts; 
            [ mpris sponsorblock webtorrent-mpv-hook thumbnail ];
        };
      })

      # Ranger sixel support
      (final: prev: {
        ranger = prev.ranger.overrideAttrs (o: {
          patches = (o.patches or [ ]) ++ [
            (final.fetchpatch {
              url = "https://github.com/3ap/ranger/commit/ef9ec1f0e0786e2935c233e4321684514c2c6553.patch";
              sha256 = "sha256-MJbIBuFeOvYnF6KntWJ2ODQ4KAcbnFEQ1axt1iQGkWY=";
            })
          ];
        });
      })
    ];
  };

  # Allow flakes (I have no clue how they work yet)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Choose an optimized kernel and boot with extra modules
  boot = {
    kernelPackages = pkgs.unstable.linuxPackages_zen;
    extraModulePackages = [ nvidiaDriver ];
    blacklistedKernelModules = [ "pcspkr" ];
    kernelParams = commonKernelParams ++ [ "vfio-pci.ids=10de:13c2,10de:0fbb" ];
    initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];

    # Change sysctl settings
    kernel.sysctl."vm.max_map_count" = 2147483642;

    # Choose GRUB as the bootloader
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        efiSupport = true;
        device = "nodev";
        theme = "${pkgs.sleek-grub-theme.override { withStyle = "dark"; }}";
      };
    };
  };

  # Add an extra kernel entry to boot from the secondary NVIDIA GPU
  specialisation = {
    gputwo.configuration = {
      boot.kernelParams = commonKernelParams ++ [ "vfio-pci.ids=10de:2504,10de:228e" ];
    };
  };

  ## Do this on ARM instead
  #boot = { 
  #  loader.grub.enable = false;
  #  loader.generic-extlinux-compatible.enable = true;
  #  kernelParams = [ "efifb=off" ];
  #};

  # Allow binary firmware
  hardware.enableRedistributableFirmware = true;

  # Enable the proprietary NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = false;
    package = nvidiaDriver;
  };

  # Define all extra drives
  fileSystems = {
    "/etc/libvirt" = {
      device = "/dev/disk/by-label/Qemu";
      options = [ "nosuid" "nodev" "nofail" ] ;
    };
    "/var/lib/libvirt" = {
      depends = [ "/etc/libvirt" ];
      device = "/etc/libvirt/varlibvirt";
      options = [ "bind" "rw" ];
    };
    "/mnt/Linux1" = {
      device = "/dev/disk/by-label/Linux1";
      options = [ "nosuid" "nodev" "nofail" "x-gvfs-show" ];
    };
    "/mnt/Linux2" = {
      device = "/dev/disk/by-label/Linux2";
      options = [ "nosuid" "nodev" "nofail" "x-gvfs-show" ];
    };
    "/mnt/Windows1" = {
      device = "/dev/disk/by-label/Windows1";
      options = [ "nosuid" "nodev" "noauto" ];
    };
    "/mnt/Windows2" = {
      device = "/dev/disk/by-label/Windows2";
      options = [ "nosuid" "nodev" "noauto" ];
    };
    "/home/jimbo/JimboNFS" = {
      device = "server:/export/JimboNFS";
      fsType = "nfs";
      options = [ "nofail" ];
    };
    "/home/jimbo/SenecaMount" = {
      device = "//mydrive.senecacollege.ca/courses/";
      fsType = "cifs";
      options = [ "noauto" "username=jhampton1" "workgroup=seneds.senecacollege.ca" "uid=1000" "gid=100" ];
    };
  };

  # Create the sudoers file
  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [
        # Give wheel root access, don't ask for password every time
        { groups = [ "wheel" ]; keepEnv = true; persist = true; }
      ];
    };
  };

  # Enable ZSH as a possible shell for users
  programs.zsh.enable = true;

  # Define a user account.
  users.users.jimbo = {
    isNormalUser = true;
    description = "Jimbo";
    hashedPassword = 
      "$6$gYpE.pG/zPXgin06$2kydjDfd0K62Dhf9P0PFvJhRNz6xIC/bHYaf/XYqyKcLyZNzPQpy8uy9tCRcSYlj1wwBhzVtTRyItwajOHCEj0";
    extraGroups = [ 
      "wheel" "audio" "video"
      "input" "disk" "networkmanager"
      "kvm" "libvirtd" "qemu-libvirtd"
    ];
    uid = 1000;
    shell = pkgs.zsh;
  };

  # Installed programs to the system profile.
  environment.systemPackages = with pkgs; [
    # Essential system tools
    cifs-utils ntfs3g parted git

    # Printer control
    system-config-printer

    # Virtual machines
    virt-manager virtiofsd dnsmasq
    spice-vdagent looking-glass-client
  ];

  # Disable the HTML documentation link
  documentation = {
    nixos.enable = false;
    info.enable = false;
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
    ];
  };

  # Enable Steam hardware and gamemode
  hardware.steam-hardware.enable = true;
  programs.gamemode.enable = true;

  # Timezone
  time.timeZone = "America/New_York";

  # Networking settings
  networking = {
    # Set hostname
    hostName = "JimNixPC";

    # Choose networking method
    dhcpcd.enable = true;
    wireless.enable = false;
    #networkmanager.enable = true;

    # Enable Wake on Lan
    interfaces."enp42s0".wakeOnLan.enable = true;

    # Enable firewall passthrough
    firewall = {
      allowedTCPPorts = [ 
	# SSH, Cockpit, and Qbittorrent
        22 9090 8182 

	# Sunshine TCP
	47984 47989 48010
      ];
      allowedUDPPorts = [
        # Sunshine UDP
	47998 47999 48000

	# Half-Life
	27005 27015

	# Lethal Company
	7777
      ];
      allowPing = false;
    };
    extraHosts = ''
      192.168.1.18 pc
      192.168.1.17 server
      192.168.2.2 vm
    '';
    nameservers = [ 
      "server"
      "1.1.1.1"
      "9.9.9.9" 
    ];
  };

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    settings = {
      General.Experimental = "true";
      Policy.AutoEnable = "true";
    };
  };

  # Enable lingering for bluetooth and allow looking-glass permissions
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
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  # Fonts
  fonts.packages = with pkgs; [
    liberation_ttf twitter-color-emoji ubuntu_font_family noto-fonts noto-fonts-cjk 
    (nerdfonts.override { fonts = [ "UbuntuMono" ]; })
  ];

  # Enable Dconf and some portals
  services.dbus.enable = true;
  programs.dconf.enable = true;
  programs.light.enable = true;
  security.pam.services.swaylock = {};
  xdg.portal = {
    enable = true;
    config.common.default = "*";
    wlr = {
      enable = true;
      settings = {
        screencast = {
          max_fps = 60;
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or -B 00000066 -b 00000099";
        };
      };
    };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Configure greetd for remote login
  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      terminal = {
        vt = 2;
        switch = true;
      };
      default_session = {
        command = "/home/jimbo/.config/sway/start.sh";
        user = "jimbo";
      };
    };
  };

  # QT theming
  qt = {
    enable = true;
    style = "gtk2";
    platformTheme = "gtk2";
  };

  # Enable printing
  services = {
    printing = {
      enable = true;
      drivers = with pkgs; [ hplip ];
    };
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };
  };

  # Enable virtualization
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu.ovmf.enable = true;
    qemu.swtpm.enable = true;
  };

  # Used for Seneca VPN
  services.globalprotect.enable = true;

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      LogLevel = "VERBOSE";
      PermitRootLogin = lib.mkForce "no";
    };
  };
  services.fail2ban = {
    enable = true;
    maxretry = 5;
  };

  # Enable extra functionality in file managers
  services.gvfs.enable = true;

  # Enable Polkit for authentication
  security.polkit.enable = true;

  # Enable AppArmor
  security.apparmor.enable = true;

  # Determine the release version and allow auto-upgrades
  system.stateVersion = "23.11";
  system.autoUpgrade.enable = true;
}
