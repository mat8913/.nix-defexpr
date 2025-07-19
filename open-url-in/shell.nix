{ rustPlatform, glib, gtk4, pkg-config, rustfmt, cargo-edit }:

rustPlatform.buildRustPackage {
  pname = "ggui";
  version = "1";

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  src = ./.;

  nativeBuildInputs = [
    pkg-config
    rustfmt
    cargo-edit
  ];

  buildInputs = [
    glib
    gtk4
  ];
}
