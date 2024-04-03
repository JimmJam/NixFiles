{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "nvme" "usbhid" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Mounting options
  fileSystems = {
    "/" = { 
      device = "/dev/disk/by-uuid/8f81cab7-9381-4950-b77f-b85c5fdbad16";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/2034-754A";
      fsType = "vfat";
    };
    "/home/jimbo/JimboNFS" = {
      device = "/dev/disk/by-uuid/713fcd92-534c-4153-8e04-e0c6fe5f6a51";
      fsType = "ext4";
    };
    "/export/JimboNFS" = {
      device = "/home/jimbo/JimboNFS";
      fsType = "none";
      options = [ "bind" ];
    };
    "/mnt/nextcloud/data/JimboNFS" = {
      device = "/home/jimbo/JimboNFS";
      fsType = "none";
      options = [ "bind" ];
    };
  };
  swapDevices = [
    { device = "/dev/disk/by-uuid/ec422cad-bf93-4b15-b989-2c807f1073a4"; }
  ];

  # Enables DHCP on each ethernet and wireless interface.
  networking.useDHCP = lib.mkDefault true;

  # Hardware settings
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.swraid.enable = true;
}
