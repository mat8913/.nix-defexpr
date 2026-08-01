{ buildEnv
, python3
, writeScript
, writeTextDir
}:

let

script = writeScript "backups.py" ''
  #! ${python3}/bin/python3

  ${builtins.readFile ./backups.py}
'';

service = writeTextDir "/share/systemd/user/backups.service" ''
  [Service]
  ExecStart=${script}
  Type=oneshot
'';

timer = writeTextDir "/share/systemd/user/backups.timer" ''
  [Timer]
  OnCalendar=*-*-* 18:00:00 UTC
  Persistent=true

  [Install]
  WantedBy=timers.target
'';

in

buildEnv {
  name = "iron-backups";
  paths = [ service timer ];
  extraOutputsToInstall = [ "man" "doc" ];
  pathsToLink = [ "/bin" "/lib" "/share" ];
}
