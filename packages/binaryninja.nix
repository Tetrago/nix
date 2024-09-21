{
  buildFHSEnv,
  writeShellScript,
}:

buildFHSEnv {
  name = "binaryninja";

  runScript = writeShellScript "binaryninja.sh" ''
    set -e
    exec "$HOME/.local/share/binaryninja/binaryninja" "$@"
  '';

  targetPkgs =
    pkgs:
    let
      kdeDeps = with pkgs.kdePackages; [
        qtbase
        qtdeclarative
      ];
      xorgDeps = with pkgs.xorg; [
        libX11
        libxcb
        xcbutilimage
        xcbutilkeysyms
        xcbutilrenderutil
        xcbutilwm
      ];
    in
    with pkgs;
    [
      dbus
      fontconfig
      freetype
      libGL
      libxkbcommon
      libxml2
      (python3.withPackages (p: with p; [ torch ]))
      stdenv.cc.cc
      wayland
      zlib
    ]
    ++ kdeDeps
    ++ xorgDeps;

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cat > $out/share/applications/binaryninja.desktop <<EOF
    [Desktop Entry]
    Name=Binary Ninja
    Exec=binaryninja %u
    Terminal=false
    Type=Application
    MimeType=application/x-binaryninja;x-scheme-handler/binaryninja
    Categories=Utility
    Comment=Binary Ninja: A Reverse Engineering Platform
    EOF
  '';
}
