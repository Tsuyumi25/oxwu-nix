{
  description = "地牛Wake Up! 台灣地震速報 Nix package";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "armv7l-linux" ];
    in {
      packages = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          oxwu = pkgs.callPackage ./package.nix {};
        in {
          inherit oxwu;
          default = oxwu;
        }
      );
    };
}
