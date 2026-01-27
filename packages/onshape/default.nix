{
  lib,
  runCommand,
  chromium,
  imagemagick,
}:

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

    for size in 16 24 32 48 64 128 256; do
      pair=''${size}x''${size}

      mkdir -p $out/share/icons/hicolor/$pair/apps
      ${imagemagick}/bin/magick \
        -density 512 \
        -background none \
        ${./icon.svg} \
        -resize $pair \
        -gravity center \
        -extent $pair \
        $out/share/icons/hicolor/$pair/apps/onshape.png
    done

  mkdir -p $out/share/applications
  cat <<EOF > $out/share/applications/onshape.desktop
  [Desktop Entry]
  Name=Onshape
  Exec=onshape
  Icon=onshape
  Type=Application
  EOF
''
