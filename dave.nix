{ config, lib, pkgs, ... }:
{
  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
  };

  services = {
    geoipupdate = {
      enable = true;
      settings = {
        AccountID = 847162;
        EditionIDs = [
          "GeoLite2-ASN"
          "GeoLite2-City"
          "GeoLite2-Country"
        ];
        LicenseKey = "/etc/maxmind.key";
      };
    };
    ntopng = {
      enable = true;
      interfaces = [ "switch" ];
      extraConfig = ''
        --disable-login=0
        --http-port=80
        --https-port=443
      '';
    };
  };
}
