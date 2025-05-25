{ runCommand }:

runCommand "my-swayconf" { } ''
  mkdir -p $out/etc/
  mkdir -p $out/libexec/my-swayconf/

  cp ${./sway.conf} $out/etc/my-sway.conf
  cp ${./post-start.sh} $out/libexec/my-swayconf/post-start.sh
  chmod +x $out/libexec/my-swayconf/post-start.sh
''
