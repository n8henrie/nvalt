{
  description = "Flake to resurrect Notational Velocity";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-old-openssl.url = "github:nixos/nixpkgs/release-21.11";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-old-openssl,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-old-openssl = import nixpkgs-old-openssl {
        inherit system;
        config.permittedInsecurePackages = [ "openssl-1.0.2u" ];
      };
    in
    {
      packages.${system} = {
        mmd4 = pkgs.callPackage ./mmd4.nix { };
        deps = pkgs.symlinkJoin {
          name = "nvalt-deps";
          paths = [
            self.outputs.packages.${system}.mmd4
          ]
          ++ (with pkgs-old-openssl.openssl_1_0_2; [
            out
            dev
          ]);
        };
      };
      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ self.outputs.packages.${system}.default ];
      };
    };
}
