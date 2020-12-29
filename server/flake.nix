{
  description = "my project description";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.haskell-nix = {
    url = "github:input-output-hk/haskell.nix?rev=c9dde4d9f4ad8eeaa117522563bdec0a4ff5a353";
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat, haskell-nix }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          # pkgs = nixpkgs.legacyPackages.${system};
          # pkgs0 = nixpkgs.legacyPackages.${system};
          pkgs = haskell-nix.legacyPackages.${system};
          ghc = pkgs.haskellPackages.ghcWithHoogle (pkgs: [
            pkgs.aws-lambda-haskell-runtime
            pkgs.stripe-haskell
            pkgs.aeson
          ]);
        in
        {
          nixpkgs = nixpkgs;
          devShell = pkgs.mkShell
            {
              # buildInputs = [ ghc pkgs.stack pkgs.haskellPackages.haskell-language-server pkgs.ghcid ];
              buildInputs = [ ];
            };
          defaultPackage = pkgs.haskell-nix.project {
            # 'cleanGit' cleans a source directory based on the files known by git
            src = pkgs.haskell-nix.haskellLib.cleanGit {
              name = "haskell-nix-project";
              src = ./.;
            };
            # Specify the GHC version to use.
            compiler-nix-name = "ghc8102"; # Not required for `stack.yaml` based projects.
          };
        }
      );
}
