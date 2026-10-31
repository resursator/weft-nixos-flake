{
  description = "Weft voxel sandbox engine";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "26.10.3";

      src = pkgs.fetchFromGitHub {
        owner = "Weft-Rust";
        repo = "Weft";
        rev = "v${version}";
        hash = "sha256-+xo01xp+Q2VrYgSlhBp6K/5btHgbAaFIcgvWfaZPbK8=";
      };

      weft = pkgs.callPackage ./package.nix {
        inherit src version;
      };
    in
    {
      packages.${system} = {
        inherit weft;
        default = weft;
      };

      apps.${system} = {
        weft = {
          type = "app";
          program = "${weft}/bin/weft";
        };

        default = self.apps.${system}.weft;
      };
    };
}
