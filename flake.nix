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
          specialArgs = {
            inherit inputs outputs self;
            hostName = "w530";
            ipAddress = "100.71.196.98";
            kubeConfig = "/etc/rancher/k3s/k3s.yaml";
          };
          modules = [
            ./hosts/w530/configuration.nix
          ];
        };
      };
    };
}
