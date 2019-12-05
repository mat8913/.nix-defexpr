rec {

  nixpkgs = import ./channels/nixos {};

  git-annex-remote-rclone = nixpkgs.callPackage ./git-annex-remote-rclone {};

  passman-core = nixpkgs.haskell.lib.doJailbreak nixpkgs.haskellPackages.passman-core;

  passman-cli = nixpkgs.haskell.lib.doJailbreak (nixpkgs.haskellPackages.passman-cli.override {inherit passman-core;});

}
