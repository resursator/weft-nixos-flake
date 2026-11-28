{
  description = "Weft voxel sandbox engine (portals-next)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "26.11.8-portals";

      src = pkgs.fetchFromGitHub {
        name = "weft-${version}-source";
        owner = "Yeyti";
        repo = "Weft";
        rev = "26276fb13234e0da7e1742a21a83d0df534a90e5";
        hash = "sha256-SHkdI/rGxgMf9khXkFVcbosFsN/uyLjrJ/WUmeR/zPY=";
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
