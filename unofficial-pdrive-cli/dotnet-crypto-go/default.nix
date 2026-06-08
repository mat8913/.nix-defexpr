{ lib, buildGoModule, callPackage }:


(buildGoModule (finalAttrs: {
  pname = "dotnet-crypto-go";
  version = "0.10.4";

  src = (callPackage ../sources.nix { }).dotnet-crypto;

  sourceRoot = "${finalAttrs.src.name}/src/go";

  vendorHash = "sha256-BDiwXkuM5NobdfmsS4fGpprCEvNxH+qQ/SE2/4hiB08=";
}))
# Workaround for https://github.com/NixOS/nixpkgs/issues/379710
# Workaround for https://github.com/NixOS/nixpkgs/pull/470709#issuecomment-3709321538
.overrideAttrs (
  finalAttrs: previousAttrs: {
    buildPhase = ''
      runHook preBuild

      go build -buildmode=c-shared -mod=vendor -trimpath .

      runHook postBuild
    '';
    installPhase = ''
        mkdir -p "$out"/lib
        cp extern "$out"/lib/libproton_crypto.so
    '';
  }
)
