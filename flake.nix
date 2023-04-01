{
  description = "dave moves the packets";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils, devshell,
  }:
  let
    inherit (nixpkgs) lib;

    name = "dave";
  in
  {
    nixosConfigurations."${name}" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hw.nix ./configuration.nix ./network.nix ./dave.nix
        {
          system = {
            inherit name;
            configurationRevision = lib.mkIf (self ? rev) self.rev;
          };
        }
      ];
    };
  } // (flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        devshell.overlays.default
      ];
    };
  in {
    devShells.default = pkgs.devshell.mkShell {
      packages = with pkgs; [
        nixos-rebuild
      ];

      commands = [
        {
          name = "build";
          help = "build the system";
          command = "${pkgs.nix}/bin/nix build .#nixosConfigurations.${name}.config.system.build.toplevel";
        }
        {
          name = "deploy";
          help = "deploy the system";
          command = ''nixos-rebuild switch --flake .#${name} --use-remote-sudo --target-host "$@"'';
        }
      ];
    };
  }));
}
