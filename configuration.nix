{ config, pkgs, options, lib, ... }: 
let
  # Import home manager, set common boot paramaters
  home-manager = fetchTarball 
    "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
  commonKernelParams = [
    # Disable the PC Speaker
    "modprobe.blacklist=pcspkr"

    # Nvidia performance options
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"

    # VM/GPU passthrough
    "kvm"
    "kvm_amd"
    "amd_iommu=on"
    "iommu=pt"
    "irqpoll"
    "nested=1"

    # Force GPUs into separate IOMMU groups
    "pcie_acs_override=downstream,multifunction"
    "pci=routeirq"
    "pci=noats"
    "allow_unsafe_interrupts=1"
    "ignore_msrs=1"

    # VM gaming performance
    "transparent_hugepage=always"
  ];
  nvidiaDriver = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
in

{
  # Import other nix files and firmware
  imports = [ 
    ./hardware-configuration.nix ./jimbo.nix "${home-manager}/nixos"
    #"${builtins.fetchTarball 
    #  { url = "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz"; }}/pine64/pinebook-pro"
  ];

  # Allow unfree packages and accept packages from the Nix User Repos
  nixpkgs = {
    config = {
      allowUnfree = true;
      #allowUnsupportedSystem = true;
      permittedInsecurePackages = [ "electron-24.8.6" ];
      packageOverrides = pkgs: {
        unstable = import (builtins.fetchTarball 
          "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
          inherit pkgs;
          config = { 
	    allowUnfree = true; 
	    #allowUnsupportedSystem = true;
	  };
          overlays = [
            (final: prev: {
              wlroots_0_16 = prev.wlroots_0_16.overrideAttrs (o: {
                patches = (o.patches or [ ]) ++ [ 
                  (final.fetchpatch {
                    url = "https://raw.githubusercontent.com/JimmJam/NixFiles/main/patches/nvidia.patch";
                    sha256 = "cpOzc3Y1a5F6UscgijBZJ0CXkceaF9t7aWQVLF76/1A=";
                  })
                  (final.fetchpatch {
                    url = "https://raw.githubusercontent.com/JimmJam/NixFiles/main/patches/dmabuf-capture-example.patch";
                    sha256 = "PIO9EiwJZQsVp07YkfRsLu978AX2sdlg2LbRvldIuzc=";
                  })
                  (final.fetchpatch {
                    url = "https://raw.githubusercontent.com/JimmJam/NixFiles/main/patches/screenshare.patch";
                    sha256 = "azvSsmGHR1uJe0k2hnaP6RCXfQnatpbGTMpDy9EPAr0=";
                  })
                ];
              });
            })
          ];
        };
        superstable = import (builtins.fetchTarball 
          "https://github.com/NixOS/nixpkgs/archive/nixos-23.05.tar.gz") {
          inherit pkgs;
	};
        nur = import (builtins.fetchTarball 
          "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
	};
      };
    };

    # Package overlays/patches
    overlays = [
      # MPV scripts
      (self: super: {
        mpv = super.mpv.override {
          scripts = with self.mpvScripts; 
            [ mpris sponsorblock thumbnail webtorrent-mpv-hook ];
        };
      })
    ];
  };

  # Allow flakes (I have no clue how they work yet)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Change to a more optimized kernel and choose to boot with Nvidia drivers if available
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    extraModulePackages = [ nvidiaDriver ]; 
    kernelParams = commonKernelParams ++ [ "vfio-pci.ids=10de:13c2,10de:0fbb" ];
    initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" "nvidia" ];

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
  #  kernelPackages = pkgs.linuxPackages_latest;
  #  loader.grub.enable = false;
  #  loader.generic-extlinux-compatible.enable = true;
  #  kernelParams = [ "efifb=off" ];
  #};

  # Allow unfree firmware for AMD, Bluetooth, etc
  hardware.enableAllFirmware = true;

  # Update CPU Microcode
  hardware.cpu.amd.updateMicrocode = true;

  # Enable the proprietary NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = false;
    forceFullCompositionPipeline = true;
    package = nvidiaDriver;
  };

  # Define all extra drives
  fileSystems = {
    "/etc/libvirt" = {
      device = "/dev/disk/by-label/Qemu";
      options = ["nosuid,nodev,nofail"] ;
    };
    "/var/lib/libvirt" = {
      depends = [ "/etc/libvirt" ];
      device = "/etc/libvirt/varlibvirt";
      options = [ "bind" "rw" ];
    };
    "/mnt/Linux1" = {
      device = "/dev/disk/by-label/Linux1";
      options = ["nosuid,nodev,nofail,x-gvfs-show"];
    };
    "/mnt/Linux2" = {
      device = "/dev/disk/by-label/Linux2";
      options = ["nosuid,nodev,nofail,x-gvfs-show"];
    };
    "/mnt/Windows1" = {
      device = "/dev/disk/by-label/Windows1";
      options = ["nosuid,nodev,nofail,noauto"];
    };
    "/mnt/Windows2" = {
      device = "/dev/disk/by-label/Windows2";
      options = ["nosuid,nodev,nofail,noauto"];
    };
    "/home/jimbo/JimboNFS" = {
      device = "server:/export/JimboSMB";
      fsType = "nfs";
      options = ["nofail"];
    };
    "/home/jimbo/SenecaMount" = {
      device = "//mydrive.senecacollege.ca/courses/";
      fsType = "cifs";
      options = ["noauto,username=jhampton1,workgroup=seneds.senecacollege.ca,uid=1000,gid=100"];
    };
  };

  # Create the sudoers file
  security = {
    sudo.enable = false;
    doas = {
    enable = true;
      extraRules = [
	# Allow wheel to execute as root, allow a semi-persistant session
        { groups = [ "wheel" ]; keepEnv = true; persist = true; }
      ];
    };
  };

  # Enable ZSH as a possible shell for users
  programs.zsh.enable = true;

  # Define a user account.
  users.users.jimbo = {
    isNormalUser = true;
    hashedPassword = 
      "$6$gYpE.pG/zPXgin06$2kydjDfd0K62Dhf9P0PFvJhRNz6xIC/bHYaf/XYqyKcLyZNzPQpy8uy9tCRcSYlj1wwBhzVtTRyItwajOHCEj0";
    extraGroups = [ "wheel" "audio" "video" "libvirtd" ];
    uid = 1000;
    shell = pkgs.zsh;
  };

  # Installed programs to the system profile.
  environment.systemPackages = with pkgs; [
    # Essential system tools
    cifs-utils ntfs3g git parted btrfs-progs

    # Printer drivers
    hplipWithPlugin

    # Virtual machines
    virtiofsd virt-manager swtpm dnsmasq
    spice-vdagent looking-glass-client

    # Cockpit machines
    nur.repos.dukzcry.cockpit-machines
    nur.repos.dukzcry.libvirt-dbus
  ];

  # Disable the HTML documentation link
  documentation.nixos.enable = false;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Enable Steam hardware and gamemode
  hardware.steam-hardware.enable = true;
  programs.gamemode.enable = true;

  # Define timezone and networking settings
  time.timeZone = "America/New_York";
  networking = let 
    localspan = ''192.168.1'';
    vmspan = ''192.168.2'';
  in {
    hostName = "JimNixPC";
    dhcpcd.enable = true;
    wireless.enable = false;
    #networkmanager.enable = true;
    wireless.iwd.enable = true;
    firewall = {
      allowedTCPPorts = [ 
	# SSH, Cockpit, and Qbittorrent
        22 9090 8182 

	# Sunshine TCP
	47984 47989 47990 48010
      ];
      allowedUDPPorts = [
        # Sunshine UDP
	47998 47999 48000
      ];
      allowPing = false;
    };
    extraHosts = ''
      ${localspan}.18 pc
      ${localspan}.17 server
      ${vmspan}.2 vm
    '';
    nameservers = [ 
      "server"
      "1.1.1.1"
      "9.9.9.9" 
    ];
  };

  # Enable AppArmor
  security.apparmor.enable = true;

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    settings = {
      General.Experimental = "true";
      Policy.AutoEnable = "true";
    };
  };
  services.blueman.enable = true;

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
    settings = rec {
      terminal = {
        vt = 2;
        switch = true;
      };
      initial_session = {
        command = "/home/jimbo/.config/sway/start.sh";
        user = "jimbo";
      };
      default_session = initial_session;
    };
  };

  # Have the possibility of not enabling greetd by default
  #systemd.services.greetd.wantedBy = lib.mkForce [];

  # QT theming
  qt.enable = true;
  qt.platformTheme = "gtk2";

  # Enable CUPS for printing
  services.printing.enable = true;

  # Enable virtualization
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu.ovmf.enable = true;
  };

  # Enable Cockpit and SSH
  services.openssh.enable = true;
  services.cockpit.enable = true;

  # Enable Polkit for authentication
  security.polkit.enable = true;

  # Determine the release version and allow auto-upgrades
  system.stateVersion = "23.11";
  system.autoUpgrade.enable = true;
}
