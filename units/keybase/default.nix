{ writeTextFile, keybase }:

writeTextFile {
  name = "keybase.service";
  destination = "/lib/systemd/user/keybase.service";
  text = ''
    [Unit]
    Description=Keybase core service

    [Service]
    # "notify" means we promise to call SdNotify() at the end of startup.
    Type=notify
    Environment=KEYBASE_SERVICE_TYPE=systemd

    # Backwards-compatibility
    EnvironmentFile=-%t/keybase/keybase.env

    # Use %h/.config instead of %E because %E isn't supported in systemd 229
    # though this breaks non-standard $XDG_CONFIG_HOMEs.
    # See GetEnvFileDir; change when Debian
    # updates to a systemd version accepting %E.
    EnvironmentFile=-%h/.config/keybase/keybase.autogen.env
    EnvironmentFile=-%h/.config/keybase/keybase.env

    ExecStart=${keybase}/bin/keybase --use-default-log-file --debug service
    Restart=on-failure

    [Install]
    WantedBy=default.target
  '';
}
