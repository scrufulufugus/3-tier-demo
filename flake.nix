{
  description = "Application packaged using poetry2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    middleware = {
      url = "path:middleware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    frontend = {
      url = "path:frontend";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, middleware, frontend, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          frontend3Tier = frontend.packages.${system}.default;
          middleware3Tier = middleware.packages.${system}.default;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.frontend3Tier self.packages.${system}.middleware3Tier ];
          packages = with pkgs; [ poetry yarn ];
        };
      });
}
