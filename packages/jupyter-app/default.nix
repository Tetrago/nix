{
  chromium,
  flock,
  imagemagick,
  iproute2,
  lib,
  makeWrapper,
  nodejs,
  python3,
  runCommand,
  ...
}:

let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      ipython
      jupyter
      jupyter-lsp
      matplotlib
      numpy
      pandas
      python-lsp-server
      python-lsp-ruff
      scipy
    ]
  );
in
runCommand "jupyter-app"
  {
    nativeBuildInputs = [
      makeWrapper
    ];
  }
  ''
    for size in 16 24 32 48 64 128 256; do
      pair="''${size}x''${size}"

      mkdir -p "$out/share/icons/hicolor/$pair/apps"
      ${imagemagick}/bin/magick \
        -density 512 \
        -background none \
        ${./icon.svg} \
        -resize $pair \
        -gravity center \
        -extent "$pair" \
        "$out/share/icons/hicolor/$pair/apps/jupyter-app.png"
    done

    mkdir -p "$out/bin"
    makeWrapper ${./launch} "$out/bin/jupyter-app" \
      --prefix PATH : ${
        lib.makeBinPath [
          chromium
          flock
          iproute2
          nodejs
          pythonEnv
        ]
      }

    mkdir -p $out/share/applications
    cat <<EOF > $out/share/applications/jupyter-app.desktop
    [Desktop Entry]
    Name=Jupyter
    Exec=jupyter-app
    Icon=jupyter-app
    Type=Application
    Terminal=false
    EOF
  ''
