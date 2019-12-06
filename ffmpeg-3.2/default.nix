{ stdenv, callPackage, fetchpatch
# Darwin frameworks
, Cocoa, CoreMedia
, ...
}@args:

callPackage ../channels/nixos/pkgs/development/libraries/ffmpeg/generic.nix (args // rec {
  version = "${branch}";
  branch = "3.2.14";
  sha256 = "15p01rrrbpm75zq5djqp28qvv6ylnjjcj0dg7vq6bs0jxhyby66r";
  darwinFrameworks = [ Cocoa CoreMedia ];
})
