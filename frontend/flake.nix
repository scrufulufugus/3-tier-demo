{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          frontend3Tier = pkgs.mkYarnPackage {
            name = "frontend3Tier";
            src = ./.;
            packageJSON = ./package.json;
            yarnLock = ./yarn.lock;
          };
          default = self.packages.${system}.frontend3Tier;
        };
      });
}
