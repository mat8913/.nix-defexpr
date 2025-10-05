{ ... }:

let

packageOverrides = pkgs: rec {
  sway-unwrapped = pkgs.sway-unwrapped.overrideAttrs (
    finalAttrs: previousAttrs: {
      patches = (previousAttrs.patches or []) ++ [ ./sway-patches/inhibit-fullscreen.patch ];
    }
  );

  aria2 = pkgs.aria2.overrideAttrs (
    finalAttrs: previousAttrs: {
      patches = (previousAttrs.patches or []) ++ [ ./aria-patches/remove-max-limit.patch ];
    }
  );

  ranger = pkgs.ranger.overrideAttrs (
    finalAttrs: previousAttrs: {
      patches = (previousAttrs.patches or []) ++ [ ./ranger-patches/fix-bulkrename.patch ];
    }
  );

  mpv = pkgs.mpv-unwrapped.wrapper {
    mpv = pkgs.mpv-unwrapped;

    scripts = with pkgs.mpvScripts; [
      mpris
    ];
  };

  python3 = pkgs.python3.override {
    packageOverrides = self: super: {
      py-natpmp = pkgs.python3Packages.callPackage ./py-natpmp {};
    };
    self = python3;
  };

  unofficial-pdrive-cli = (pkgs.callPackage ./unofficial-pdrive-cli { }).unofficial-pdrive-cli;
};

pkgs = rec {

  inherit pkgs;
  inherit (nixpkgs) runCommand bashInteractive;

  nixpkgs = import ./channels/nixos { config = { packageOverrides = packageOverrides; }; };

  my-profile-text = nixpkgs.writeText "my-profile" ''
    export GTK_THEME=Adwaita:dark
  '';

  my-profile = nixpkgs.runCommand "profile" { } ''
    mkdir -p $out/etc/profile.d
    cp ${my-profile-text} $out/etc/profile.d/my-profile.sh
  '';

  my-bashrc = nixpkgs.writeTextDir "/etc/bashrc.d/my-bashrc.sh" ''
    function r {
      local temp_file="$(mktemp -p /run/user/1000 -t "ranger_cd.XXXXXXXXXX")"
      ranger --choosedir="$temp_file" "$@"
      return_value="$?"
      if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
        cd -- "$chosen_dir"
      fi
      rm -f -- "$temp_file"
      return "$return_value"
    }
  '';

  my-gitconfig-text = nixpkgs.writeText "my-gitconfig" ''
    [user]
      name = Matthew Harm Bekkema
      email = id@mbekkema.name
    [push]
      default = simple
    [core]
      autocrlf = off
    [pull]
      ff = only
    [safe]
      directory = /etc/nixos/.git
  '';

  my-gitconfig = nixpkgs.runCommand "my-gitconfig" { } ''
    mkdir -p $out/etc/
    cp ${my-gitconfig-text} $out/etc/gitconfig
  '';

  my-alacrittyconf = nixpkgs.writeTextDir "/etc/alacritty.toml" ''
    [hints]
    enabled = []
  '';

  my-xdg-desktop-portals-conf = nixpkgs.writeTextDir "/etc/xdg-desktop-portals.conf" ''
    [preferred]
    default=gtk
    org.freedesktop.impl.portal.Inhibit=none
  '';

  my-installconf = nixpkgs.stdenvNoCC.mkDerivation {
    pname = "installconf";
    version = "1";

    src = nixpkgs.writeShellScriptBin "installconf" ''
      mkdir -p ~/.config/alacritty
      ln -sf ../../.nix-profile/etc/alacritty.toml ~/.config/alacritty/

      mkdir -p ~/.config/xdg-desktop-portal
      ln -sf ../../.nix-profile/etc/xdg-desktop-portals.conf ~/.config/xdg-desktop-portal/portals.conf

      ${nixpkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
      ${nixpkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    '';

    nativeBuildInputs = [
      nixpkgs.wrapGAppsNoGuiHook
    ];

    buildInputs = [
      nixpkgs.glib
      nixpkgs.gsettings-desktop-schemas
    ];

    installPhase = ''
      mkdir -p $out/
      cp -r bin $out/
    '';
  };

  my-scripts = nixpkgs.callPackage ./my-scripts { };

  my-swayconf = nixpkgs.callPackage ./my-swayconf { };

  my-statusbar = nixpkgs.callPackage ./my-statusbar { };

  open-url-in = nixpkgs.callPackage ./open-url-in { };

  runsway-text = nixpkgs.writeText "runsway-text" ''
    #!/bin/sh

    exec systemd-run --user --scope -u sway -G -- sway --config "$HOME"/.nix-profile/etc/my-sway.conf
  '';

  runsway = nixpkgs.runCommand "runsway" { } ''
    mkdir -p $out/bin
    cp ${runsway-text} $out/bin/runsway
    chmod +x $out/bin/runsway
  '';

  my-syncthing-service = nixpkgs.runCommand "my-syncthing-service" {} ''
    mkdir -p $out/share/systemd/user/
    cp ${nixpkgs.syncthing}/share/systemd/user/syncthing.service $out/share/systemd/user/
    chmod 644 $out/share/systemd/user/syncthing.service
    cat >> $out/share/systemd/user/syncthing.service <<EOF

    [Service]
    PrivateUsers=yes
    ProtectHome=tmpfs
    BindPaths=%h/Sync
    BindPaths=%S/syncthing
    EOF
  '';

  reset-doc-permissions-script = nixpkgs.writeShellScriptBin "reset-doc-permissions" ''
    for i in `${nixpkgs.flatpak}/bin/flatpak permissions documents | ${nixpkgs.coreutils}/bin/cut --delimiter='	' --fields=2 | ${nixpkgs.coreutils}/bin/sort -u`; do
      ${nixpkgs.flatpak}/bin/flatpak permission-remove documents "$i"
    done
  '';

  reset-doc-permissions-service = nixpkgs.writeTextDir "/share/systemd/user/reset-doc-permissions.service" ''
    [Service]
    ExecStart=${reset-doc-permissions-script}/bin/reset-doc-permissions
    Type=oneshot

    [Install]
    WantedBy=default.target
  '';

  my-vim = nixpkgs.vim-full.customize {
    vimrcConfig.customRC = ''
      syntax on
      set directory=~/.vim/tmp//  " Trailing // is important, see :help directory
      set number
      set hlsearch
      imap <Tab> <Esc>

      set autoindent
      set noexpandtab

      set wildmenu
      set wildmode=longest:full,full

      set list
      set listchars=tab:▸\ ,trail:.

      nore ; :
      nore , ;

      set background=dark
      hi SpellBad cterm=underline

      set laststatus=2
      set noshowmode

      autocmd FileType gitcommit setlocal textwidth=72 spell
      autocmd FileType cabal setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
      autocmd FileType typescript setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
      autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
      autocmd FileType rust setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
      autocmd FileType nix setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
    '';

    vimrcConfig.packages.my-vim-package = with nixpkgs.vimPlugins; {
      start = [
        vim-wayland-clipboard
      ];
    };
  };

  # Remove /etc output to override with my own
  my-swaync = nixpkgs.buildEnv {
    name = "my-swaync";
    paths = [ nixpkgs.swaynotificationcenter ];
    extraOutputsToInstall = [ "man" "doc" ];
    pathsToLink = [ "/bin" "/lib" "/share" ];
  };

  backups = nixpkgs.callPackage ./backups {};

  userwgns = nixpkgs.callPackage ./userwgns {};

  natpmploop = nixpkgs.callPackage ./natpmploop {};

  iron-packages = nixpkgs.buildEnv {
    name = "iron-packages";
    paths = [
      nixpkgs.mpv
      nixpkgs.alacritty
      nixpkgs.blueman
      nixpkgs.git
      nixpkgs.gnupg
      nixpkgs.pavucontrol
      nixpkgs.pinentry-qt
      nixpkgs.sway
      nixpkgs.swaylock-effects
      nixpkgs.wl-clipboard
      nixpkgs.xclip
      nixpkgs.yt-dlp
      nixpkgs.aria2
      nixpkgs.wofi
      (nixpkgs.pass-wayland.withExtensions (ext: with ext; [ pass-otp ]))
      nixpkgs.ranger
      nixpkgs.adwaita-icon-theme
      nixpkgs.imv
      nixpkgs.gammastep

      backups

      my-vim
      my-profile
      my-bashrc
      my-gitconfig
      my-alacrittyconf
      my-xdg-desktop-portals-conf
      my-swayconf
      my-statusbar
      my-scripts
      my-installconf
      my-swaync
      my-syncthing-service

      runsway
      reset-doc-permissions-service
      open-url-in
      userwgns
      natpmploop
    ];
    extraOutputsToInstall = [ "man" "doc" ];
  };

};

in pkgs
