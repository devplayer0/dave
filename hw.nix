{ config, lib, pkgs, modulesPath, ... }:
{
  hardware = {
    enableRedistributableFirmware = true;
    firmware = with pkgs; [
      # shitty broadcom firmware...
      (runCommand "brcm-extra" {} ''
        mkdir -p "$out"/lib/firmware
        cp -r ${./misc/brcm} "$out"/lib/firmware/brcm
      '')
    ];
    cpu.intel.updateMicrocode = true;
  };

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_acpi" ];
    kernelModules = [ "kvm-intel" ];
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/56cdaeed-4555-44f1-b180-e6fbe2e38d3d";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/826A-33B5";
      fsType = "vfat";
    };
  };
}
