{ ... }:

let

packageOverrides = pkgs: rec {
  sway-unwrapped = pkgs.sway-unwrapped.overrideAttrs (
    finalAttrs: previousAttrs: {
      patches = previousAttrs.patches ++ [ ./sway-patches/inhibit-fullscreen.patch ];
    }
  );
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

  my-scripts = nixpkgs.callPackage ./my-scripts { };

  my-swayconf = nixpkgs.callPackage ./my-swayconf { };

  runsway-text = nixpkgs.writeText "runsway-text" ''
    #!/bin/sh

    exec systemd-run --user --scope -u sway -G -- sway --config "$HOME"/.nix-profile/etc/my-sway.conf
  '';

  runsway = nixpkgs.runCommand "runsway" { } ''
    mkdir -p $out/bin
    cp ${runsway-text} $out/bin/runsway
    chmod +x $out/bin/runsway
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
      autocmd FileType nix setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
    '';

    vimrcConfig.packages.my-vim-package = with nixpkgs.vimPlugins; {
      start = [
        vim-wayland-clipboard
      ];
    };
  };

  iron-packages = nixpkgs.buildEnv {
    name = "iron-packages";
    paths = [
      nixpkgs.mpv
      nixpkgs.alacritty
      nixpkgs.blueman
      nixpkgs.git
      nixpkgs.gnupg
      nixpkgs.mpv
      nixpkgs.pavucontrol
      nixpkgs.pinentry-qt
      nixpkgs.sway
      nixpkgs.wl-clipboard
      nixpkgs.xclip
      nixpkgs.yt-dlp
      nixpkgs.aria2
      nixpkgs.wofi
      nixpkgs.pass-wayland
      nixpkgs.ranger

      my-vim
      my-profile
      my-bashrc
      my-gitconfig
      my-alacrittyconf
      my-swayconf
      my-scripts

      runsway
    ];
    extraOutputsToInstall = [ "man" "doc" ];
  };

};

in pkgs
