{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    middleware = {
      url = "path:middleware";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    frontend = {
      url = "path:frontend";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, middleware, frontend, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        pkgs = nixpkgs.legacyPackages.${system};
        frontend3Tier = frontend.packages.${system}.frontend3Tier;
        middleware3Tier = middleware.packages.${system}.middleware3Tier;
      in
      {
        devShells.default = pkgs.mkShell {
          inputsFrom = [ frontend3Tier middleware3Tier ];
          packages = with pkgs; [ poetry yarn ];
        };
      });
}
