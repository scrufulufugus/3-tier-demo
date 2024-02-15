{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        pkgs = nixpkgs.legacyPackages.${system};
        middlePath = ./middleware;
        frontPath = ./frontend;
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
      in
      {
        packages = {
          middleware = mkPoetryApplication { projectDir = middlePath; };
          frontend = pkgs.mkYarnPackage {
            name = "frontend";
            src = frontPath;
            packageJSON = "${frontPath}/package.json";
            yarnLock = "${frontPath}/yarn.lock";
            #yarnNix = "${frontPath}/yarn.nix";
          };
          default = self.packages.${system}.middleware;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.frontend self.packages.${system}.middleware ];
          packages = with pkgs; [ poetry yarn ];
        };
      });
}
