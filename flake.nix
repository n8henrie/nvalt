{
  description = "Flake to resurrect Notational Velocity";

  # inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  # inputs.nixpkgs.url = "github:nixos/nixpkgs/release-25.05";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-21.11";

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.permittedInsecurePackages = [ "openssl-1.0.2u" ];
      };
    in
    {
      packages.${system} = {
        default = pkgs.callPackage ./package.nix { };
        deps = pkgs.symlinkJoin {
          name = "nvalt-deps";
          paths = with pkgs.openssl_1_0_2; [
            out
            dev
          ];
        };
      };
      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ self.outputs.packages.${system}.default ];
      };
    };
}
