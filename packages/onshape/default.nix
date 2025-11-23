{
  lib,
  runCommand,
  chromium,
}:

let
  inherit (lib.strings) concatLines;
in
runCommand "onshape" { } ''
  mkdir -p $out/bin
  cat <<EOF > $out/bin/onshape
  #!/usr/bin/env bash
  if [ "\$1" = "profile" ]; then
    exec ${lib.getExe chromium} --user-data-dir="\$HOME/.local/share/onshape"
  else
    exec ${lib.getExe chromium} --app=https://cad.onshape.com --user-data-dir="\$HOME/.local/share/onshape"
  fi
  EOF
  chmod +x $out/bin/onshape

  ${concatLines (
    map
      (
        n:
        let
          x = toString n;
          path = "$out/share/icons/hicolor/${x}x${x}/apps";
        in
        "mkdir -p ${path} && cp ${./${x}.png} ${path}/onshape.png"
      )
      [
        16
        32
        48
      ]
  )}

  mkdir -p $out/share/applications
  cat <<EOF > $out/share/applications/onshape.desktop
  [Desktop Entry]
  Name=Onshape
  Exec=onshape
  Icon=onshape
  Type=Application
  EOF
''
