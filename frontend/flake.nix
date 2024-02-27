{
  description = "Flutter UI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = pkgs.flutter.buildFlutterApplication rec {
            name = "frontend3Tier";
            pname = name;
            version = "1.0.0+1";
            src = ./.;
            autoPubspecLock = ./pubspec.lock;
          };
        };
      });
}
