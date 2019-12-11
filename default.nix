{ ... }:

let pkgs = rec {

  inherit pkgs;
  inherit (nixpkgs) runCommand bashInteractive;

  nixpkgs = import ./channels/nixos {};

  git-annex-remote-rclone = nixpkgs.callPackage ./git-annex-remote-rclone {};

  passman-core = nixpkgs.haskell.lib.doJailbreak nixpkgs.haskellPackages.passman-core;

  passman-cli = nixpkgs.haskell.lib.doJailbreak (nixpkgs.haskellPackages.passman-cli.override {inherit passman-core;});

  myanimelist-export = nixpkgs.haskell.lib.doJailbreak (nixpkgs.haskell.lib.markUnbroken nixpkgs.haskellPackages.myanimelist-export);

  twitch-chatlog = (nixpkgs.callPackage ./twitch-chatlog {}).twitch-chatlog;

  ffmpeg-3_2 = nixpkgs.callPackage ./ffmpeg-3.2 {
    inherit (nixpkgs.darwin.apple_sdk.frameworks) Cocoa CoreMedia;
  };

  youtubeDL-3_2 = nixpkgs.youtubeDL.override {ffmpeg_4 = ffmpeg-3_2;};

  tubeup = nixpkgs.callPackage ./tubeup {};

  gallium-packages = nixpkgs.buildEnv {
    name = "gallium-packages";
    paths = [
      nixpkgs.gitAndTools.git-annex
      nixpkgs.gitAndTools.gitRemoteGcrypt
      nixpkgs.gnupg
      nixpkgs.mpv
      nixpkgs.powerline-fonts
      nixpkgs.taskwarrior
      nixpkgs.brave
      git-annex-remote-rclone
      (nixpkgs.pass.withExtensions (exts: [exts.pass-otp]))

      passman-cli
      myanimelist-export
    ];
    extraOutputsToInstall = [ "man" "doc" ];
  };

};

in pkgs
