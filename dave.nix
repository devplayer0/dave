{ config, lib, pkgs, ... }:
let
  cp-dave-images =
    lib.concatMapStringsSep "\n"
      (i: ''cp ${./misc/plymouth/dave-${toString i}.png} "$target"/dave-${toString i}.png'')
      (lib.range 0 2);
  plymouth-dave = pkgs.runCommand "plymouth-dave" {} ''
    target="$out"/share/plymouth/themes/dave
    mkdir -p "$target"

    substituteAll ${./misc/plymouth/dave.plymouth} "$target"/dave.plymouth
    cp ${./misc/plymouth/dave.script} "$target"/dave.script
    ${cp-dave-images}
  '';
in
{
  boot.plymouth = {
    enable = true;
    font = "${pkgs.comic-relief}/share/fonts/truetype/ComicRelief.ttf";
    themePackages = [ plymouth-dave ];
    theme = "dave";
  };
  # make sure we see the beautiful boot screen :)
  # (and also try and make sure ntopng is ready)
  systemd.services.plymouth-quit.preStart = ''
    sleep 10
    until ${pkgs.curl}/bin/curl -sSf http://localhost > /dev/null; do
      sleep 0.5
    done
  '';

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

    cage = {
      enable = true;
      user = "slave";
      program = pkgs.writeShellScript "dave-kiosk" ''
        exec ${pkgs.chromium}/bin/chromium-browser \
          --kiosk \
          http://localhost/lua/flows_stats.lua
      '';
    };
  };
}
