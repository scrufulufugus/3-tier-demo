{
  description = "A three-tier application demo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
      in
      {
        packages = rec {
          frontend3Tier = pkgs.callPackage ./frontend { builder = pkgs.flutter.buildFlutterApplication; };
          middleware3Tier = pkgs.callPackage ./middleware { builder = mkPoetryApplication; };
          default = pkgs.buildEnv {
            name = "ThreeTierDemo";
            paths = [ frontend3Tier middleware3Tier ];
          };
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.frontend3Tier self.packages.${system}.middleware3Tier ];
          packages = with pkgs; [ poetry pyright flutter ];
          CHROME_EXECUTABLE = pkgs.chromedriver + "/bin/chromedriver";
        };
      });
}
