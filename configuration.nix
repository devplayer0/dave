{ config, lib, pkgs, ... }:
let
  inherit (lib) mkForce;
in
{
  system.stateVersion = "23.05";

  networking = {
    hostName = config.system.name;
    useNetworkd = true;
  };
  time.timeZone = "Europe/Dublin";
  i18n.defaultLocale = "en_IE.UTF-8";

  nix = {
    settings = {
      trusted-users = [ "@wheel" ];
      experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
    };
    # Flake-y Nix, don't care about channels
    nixPath = mkForce [ ];
  };

  services = {
    openssh.enable = true;
  };

  programs = {
    git.enable = true;
    fish.enable = true;
    # needs channels to work >:(
    command-not-found.enable = false;
    tmux.enable = true;
  };
  environment = {
    systemPackages = with pkgs; [
      helix
    ];
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
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
