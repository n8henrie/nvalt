{
  description = "Flake to resurrect Notational Velocity";

  # inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-25.05";

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.callPackage ./package.nix { };
      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ self.outputs.packages.${system}.default ];
      };
    };
}
