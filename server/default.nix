# (import
#   (
#     let
#       lock = builtins.fromJSON (builtins.readFile ./flake.lock);
#     in
#     fetchTarball {
#       url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
#       sha256 = lock.nodes.flake-compat.locked.narHash;
#     }
#   )
#   {
#     src = ./.;
#   }).defaultNix

{
  # Fetch the latest haskell.nix and import its default.nix
  haskellNix ? import (builtins.fetchTarball "https://github.com/input-output-hk/haskell.nix/archive/c9dde4d9f4ad8eeaa117522563bdec0a4ff5a353.tar.gz") { }

  # haskell.nix provides access to the nixpkgs pins which are used by our CI,
  # hence you will be more likely to get cache hits when using these.
  # But you can also just use your own, e.g. '<nixpkgs>'.
, nixpkgsSrc ? haskellNix.sources.nixpkgs-2003

  # haskell.nix provides some arguments to be passed to nixpkgs, including some
  # patches and also the haskell.nix functionality itself as an overlay.
, nixpkgsArgs ? haskellNix.nixpkgsArgs

  # import nixpkgs with overlays
, pkgs ? import nixpkgsSrc nixpkgsArgs
}: pkgs.haskell-nix.project {
  # 'cleanGit' cleans a source directory based on the files known by git
  src = pkgs.haskell-nix.haskellLib.cleanGit {
    name = "haskell-nix-project";
    src = ./.;
  };
  # Specify the GHC version to use.
  compiler-nix-name = "ghc8102"; # Not required for `stack.yaml` based projects.
}
