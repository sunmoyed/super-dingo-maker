{
  description = "Server backend for dingo maker";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-20.09";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.nixpkgs.follows = "/nixpkgs";
  };
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          devShell = pkgs.mkShell
            {
              # I'd rather use the most up to date unfortunately
              # buildInputs = [ pkgs.pulumi-bin ];
              buildInputs = [ ];
            };
        }
      );
}
