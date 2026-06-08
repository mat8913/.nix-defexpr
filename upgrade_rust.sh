#! /usr/bin/env nix-shell
#! nix-shell -i bash --packages bash cargo cargo-edit crate2nix

fix_cargo_nix() {
patch <<EOF
--- a/Cargo.nix
+++ b/Cargo.nix
@@ -3,8 +3,7 @@
 #   "generate"
 # See https://github.com/kolloch/crate2nix for more info.
 
-{ nixpkgs ? <nixpkgs>
-, pkgs ? import nixpkgs { config = {}; }
+{ pkgs
 , fetchurl ? pkgs.fetchurl
 , lib ? pkgs.lib
 , stdenv ? pkgs.stdenv
EOF
}

cd my-statusbar
cargo upgrade
cargo update
crate2nix generate
fix_cargo_nix
cd -

cd open-url-in
cargo upgrade
cargo update
crate2nix generate
fix_cargo_nix
cd -
