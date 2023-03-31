{ config, lib, pkgs, ... }:
{
  system.stateVersion = "23.05";

  networking = {
    hostName = config.system.name;
  };
  time.timeZone = "Europe/Dublin";
  i18n.defaultLocale = "en_IE.UTF-8";

  nix = {
    settings = {
      trusted-users = [ "@wheel" ];
      experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
    };
  };

  services = {
    openssh.enable = true;
  };

  programs = {
    fish.enable = true;
  };

  users = {
    defaultUserShell = pkgs.fish;
    users.slave = {
      isNormalUser = true;
      initialPassword = "packets";
      extraGroups = [
        "wheel"
      ];
      openssh.authorizedKeys.keyFiles = [
        ./.keys/dev.pub
      ];
    };
  };

  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
