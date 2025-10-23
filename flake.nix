{
  description = "homelab";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.05";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      nixosConfigurations = {
        "w530" = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs self; };
          modules = [
            ./hosts/w530/configuration.nix
          ];
        };
      };
    };
}
