{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;

  font = pkgs.stdenvNoCC.mkDerivation {
    name = "emacs-font";
    dontUnpack = true;

    src = pkgs.monaspace;

    nativeBuildInputs = with pkgs; [
      python3.pkgs.fonttools
      fontforge
    ];

    buildPhase = ''
      pyftsubset "$src/share/fonts/opentype/MonaspaceNeon-Regular.otf" \
        --layout-features="calt,liga,ss01,ss02,ss03,ss04,ss07,ss08,ss09,ss10,cv01=2,cv10,cv11,cv30,cv31" \
        --glyphs="*" \
        --output-file="./EmacsFont-Regular.otf"

      pyftsubset "$src/share/fonts/opentype/MonaspaceNeon-Bold.otf" \
        --layout-features="calt,liga,ss01,ss02,ss03,ss04,ss07,ss08,ss09,ss10,cv01=2,cv10,cv11,cv30,cv31" \
        --glyphs="*" \
        --output-file="./EmacsFont-Bold.otf"

      pyftsubset "$src/share/fonts/opentype/MonaspaceRadon-Regular.otf" \
        --layout-features="calt,liga,ss01,ss02,ss03,ss04,ss07,ss08,ss09,ss10,cv01=2,cv10,cv11,cv30,cv31" \
        --glyphs="*" \
        --output-file="./EmacsFont-Italic.otf"

      pyftsubset "$src/share/fonts/opentype/MonaspaceRadon-Bold.otf" \
        --layout-features="calt,liga,ss01,ss02,ss03,ss04,ss07,ss08,ss09,ss10,cv01=2,cv10,cv11,cv30,cv31" \
        --glyphs="*" \
        --output-file="./EmacsFont-BoldItalic.otf"

      fontforge -lang=ff -c 'Open($1); SetFontNames("EmacsFont", "Emacs Font", "Emacs Font Regular"); Generate($1);' ./EmacsFont-Regular.otf
      fontforge -lang=ff -c 'Open($1); SetFontNames("EmacsFont", "Emacs Font", "Emacs Font Bold"); Generate($1);' ./EmacsFont-Bold.otf
      fontforge -lang=ff -c 'Open($1); SetFontNames("EmacsFont", "Emacs Font", "Emacs Font Italic"); Generate($1);' ./EmacsFont-Italic.otf
      fontforge -lang=ff -c 'Open($1); SetFontNames("EmacsFont", "Emacs Font", "Emacs Font Bold Italic"); Generate($1);' ./EmacsFont-BoldItalic.otf
    '';

    installPhase = ''
      mkdir -p $out/share/fonts/opentype
      cp ./EmacsFont-* $out/share/fonts/opentype
    '';
  };
in
{
  options.james.emacs = {
    enable = mkEnableOption "emacs configuration.";
  };

  config =
    let
      cfg = config.james.emacs;
    in
    mkIf cfg.enable {
      home.packages = [
        font
        (pkgs.emacsWithPackagesFromUsePackage {
          config = ./init.org;
          defaultInitFile = true;
          alwaysEnsure = true;
        })
      ];
    };
}
