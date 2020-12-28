{
  description = "my project description";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          ghc = pkgs.haskellPackages.ghcWithHoogle (pkgs: [ ]);
        in
        {
          devShell = pkgs.mkShell
            {
              buildInputs = [ ghc pkgs.stack pkgs.haskellPackages.haskell-language-server pkgs.ghcid ];
            };
        }
      );
}
