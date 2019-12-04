{ stdenv, fetchFromGitHub, rclone, makeWrapper }:

stdenv.mkDerivation rec {
  name = "git-annex-remote-rclone-${version}";
  version = "0.6.20170819";
  rev = "e62553ede1a1dd1a563b16bd592f776b6cc3ff6c";

  src = fetchFromGitHub {
    inherit rev;
    owner = "DanielDent";
    repo = "git-annex-remote-rclone";
    sha256 = "1n2c36mhg13zmvs27b8b9rsj9ha3xiykv712fq51l6bg7789afyf";
  };

  nativeBuildInputs = [ makeWrapper ];

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp git-annex-remote-rclone $out/bin
    wrapProgram "$out/bin/git-annex-remote-rclone" \
      --prefix PATH ":" "${stdenv.lib.makeBinPath [ rclone ]}"
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/DanielDent/git-annex-remote-rclone;
    description = "Use rclone supported cloud storage providers with git-annex";
    license = licenses.gpl3;
    maintainers = [ maintainers.montag451 ];
  };
}
