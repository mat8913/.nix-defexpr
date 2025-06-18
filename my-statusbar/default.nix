{
  callPackage,
}:

let cargo_nix = callPackage ./Cargo.nix {};
in cargo_nix.rootCrate.build
