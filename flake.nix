{
  inputs = {
    nixpkgs-unstable = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations."Poison" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./default.nix ];
      };
    };
}

