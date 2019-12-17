{ stdenvNoCC, syncthing }:

stdenvNoCC.mkDerivation {
  name = "syncthing.service";
  dontUnpack = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/lib/systemd
    ln -s ${syncthing}/lib/systemd/user $out/lib/systemd/user
  '';
}
