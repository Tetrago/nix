{
  lib,
  adwaita-fonts,
  nerd-font-patcher,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "${adwaita-fonts.pname}-nerdfont";
  inherit (adwaita-fonts) version;

  src = adwaita-fonts;

  dontUnpack = true;

  buildPhase = ''
    find $src -type f -name "*.ttf" -exec sh -c '
      ${lib.getExe nerd-font-patcher} --codicons --fontawesome -q -o "$(dirname $(realpath --relative-to=$src $1))" "$1"
    ' sh {} \;
  '';

  installPhase = ''
    mkdir -p $out
    cp -r ./share $out/share
  '';
}
