{ callPackage
, copyDesktopItems
}:

let cargo_nix = callPackage ./Cargo.nix {};
in cargo_nix.rootCrate.build.overrideAttrs (
  finalAttrs: previousAttrs: {
    nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ copyDesktopItems ];

    desktopItems = [
      ./desktop
    ];
  }
)
