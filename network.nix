{ config, lib, pkgs, ... }:
{
  networking.useDHCP = false;

  systemd.network = {
    links = {
      "10-usb" = {
        matchConfig.MACAddress = "00:e0:4c:b8:0b:f5";
        linkConfig.Name = "usb-eth0";
      };
    };
    netdevs = {
      "25-switch".netdevConfig = {
        Name = "switch";
        Kind = "bridge";
      };
    };

    networks = {
      "80-builtin" = {
        matchConfig.Name = "enp1s0";
        networkConfig.Bridge = "switch";
      };
      "80-switch" = {
        matchConfig.Name = "usb-eth0";
        networkConfig.Bridge = "switch";
      };

      "85-switch" = {
        matchConfig.Name = "switch";
        DHCP = "yes";
        linkConfig.Promiscuous = true;
      };
    };
  };
}
