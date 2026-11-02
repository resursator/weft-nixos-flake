{
  description = "Weft voxel sandbox engine";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "26.11.1";

      src = pkgs.fetchFromGitHub {
        name = "weft-${version}-source";
        owner = "Weft-Rust";
        repo = "Weft";
        rev = "v${version}";
        hash = "sha256-Am3/V5P6W9GwjasJub4q4WPNKOKTQfE0wY5MGM2xEJw=";
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
