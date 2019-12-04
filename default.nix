rec {

  nixpkgs = import ./channels/nixos {};

  git-annex-remote-rclone = nixpkgs.callPackage ./git-annex-remote-rclone {};

}
