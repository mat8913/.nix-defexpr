{ buildEnv
, python3
, unofficial-pdrive-cli
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
  Environment="PDRIVE=${unofficial-pdrive-cli}/bin/unofficial-pdrive-cli"
  Type=oneshot

  PrivateUsers=yes
  PrivateTmp=yes
  ProtectHome=tmpfs
  BindReadOnlyPaths=%h/
  BindPaths=%h/.local/share/unofficial-pdrive-cli
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
