{ runCommand }:

runCommand "my-swayconf" { } ''
  mkdir -p $out/etc/xdg/
  mkdir -p $out/libexec/my-swayconf/

  cp ${./sway.conf} $out/etc/my-sway.conf
  cp ${./post-start.sh} $out/libexec/my-swayconf/post-start.sh
  cp ${./wallpaper.png} $out/etc/wallpaper.png
  chmod +x $out/libexec/my-swayconf/post-start.sh

  cp -r ${./swaync} $out/etc/xdg/swaync
''
