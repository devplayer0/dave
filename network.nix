{ config, lib, pkgs, ... }:
{
  networking.useDHCP = false;

  systemd.network = {
    networks = {
      "80-lan" = {
        matchConfig.name = "enp1s0";
        DHCP = "yes";
      };
    };
  };
}
