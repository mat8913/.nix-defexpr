{ unofficial-pdrive-http-bridge
, writeTextDir
}:

writeTextDir "/share/systemd/user/unofficial-pdrive-http-bridge.service" ''
  [Service]
  ExecStart="${unofficial-pdrive-http-bridge}/bin/unofficial-pdrive-http-bridge"
  Type=simple

  PrivateUsers=yes
  PrivateTmp=yes
  ProtectHome=tmpfs
  BindPaths=%h/.local/share/unofficial-pdrive-http-bridge

  [Install]
  WantedBy=default.target
''
