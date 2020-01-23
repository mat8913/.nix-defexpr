{ writeTextFile, kbfs }:

writeTextFile {
  name = "kbfs.service";
  destination = "/lib/systemd/user/kbfs.service";
  text = ''
    [Unit]
    Description=Keybase Filesystem service
    # Note that the "Requires" directive will cause a unit to be restarted whenever its dependency is restarted.
    # Do not issue a hard dependency on service, because kbfs can reconnect to a restarted service.
    Wants=keybase.service

    [Service]
    # "notify" means we promise to call SdNotify() at the end of startup.
    Type=notify

    Environment=PATH=/run/wrappers/bin

    # Backwards compatibility
    EnvironmentFile=-%t/keybase/keybase.kbfs.env

    EnvironmentFile=-%h/.config/keybase/keybase.autogen.env
    EnvironmentFile=-%h/.config/keybase/keybase.env

    ExecStart=${kbfs}/bin/kbfsfuse -debug -log-to-file

    Restart=on-failure

    [Install]
    WantedBy=default.target
  '';
}
