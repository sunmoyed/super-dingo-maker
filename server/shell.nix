(import
  (
    let
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    in
    fetchTarball {
      url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
      sha256 = lock.nodes.flake-compat.locked.narHash;
    }
  )
  {
    src = ./.;
  }).shellNix.default.overrideAttrs (e: { STACK_IN_NIX_SHELL = true; }) # Annoying thing we ahve to do. https://github.com/commercialhaskell/stack/issues/5008#issuecomment-647002048
