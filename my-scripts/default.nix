{ writeScript, runCommand, wl-clipboard, openbox, xwayland, xclip, bluez }:

let

  wclear = writeScript "wclear" ''
    #!/bin/sh

    exec "${wl-clipboard}"/bin/wl-copy --clear
  '';

  wpaste-pass = writeScript "wpaste-pass" ''
    #!/bin/sh

    if [ $# -ne 1 ]; then
      echo Incorrect usage
      exit 1
    fi

    exec pass "$1" | head -n 1 | head -c -1 | "${wl-clipboard}"/bin/wl-copy
  '';

  xclear = writeScript "xclear" ''
    #!/bin/sh

    exec "${xclip}"/bin/xclip -selection clipboard /dev/null
  '';

  xpaste-pass = writeScript "xpaste-pass" ''
    #!/bin/sh

    if [ $# -ne 1 ]; then
      echo Incorrect usage
      exit 1
    fi

    exec pass "$1" | head -n 1 | head -c -1 | "${xclip}"/bin/xclip -selection clipboard
  '';

  xsubsession-exec = writeScript "xsubsession-exec" ''
    #!/bin/sh

    if [ $# -ne 1 ]; then
      echo Incorrect usage
      exit 1
    fi

    export DISPLAY="$1"

    sh -c 'sleep 1; "${openbox}"/bin/openbox' &
    exec "${xwayland}"/bin/Xwayland "$DISPLAY"
  '';

  xsubsession = writeScript "xsubsession" ''
    #!/bin/sh

    if [ x"$DISPLAY" = x ]; then
      echo "DISPLAY must be set"
      exit 1
    fi

    systemd-run --user -G -- "${xsubsession-exec}" "$DISPLAY"
  '';

  connect_headphones = writeScript "connect_headphones" ''
    #!/bin/sh
    HEADPHONES_MAC_ADDR="$(cat ~/.config/headphones_mac_addr)"
    exec "${bluez}"/bin/bluetoothctl connect "$HEADPHONES_MAC_ADDR"
  '';

in
runCommand "my-scripts" { } ''
  mkdir -p "$out/bin/"

  cp "${wclear}" "$out/bin/wclear"
  cp "${wpaste-pass}" "$out/bin/wpaste-pass"
  cp "${xclear}" "$out/bin/xclear"
  cp "${xpaste-pass}" "$out/bin/xpaste-pass"
  cp "${xsubsession}" "$out/bin/xsubsession"
  cp "${connect_headphones}" "$out/bin/connect_headphones"
''
