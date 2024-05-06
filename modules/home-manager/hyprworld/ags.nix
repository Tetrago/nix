{ config, inputs, lib, pkgs, ... }:

let
  palette = import (pkgs.stdenvNoCC.mkDerivation {
    name = "hyprworld_stylesheet";

    dontUnpack = true;

    nativeBuildInputs = with pkgs; [
      okolors
    ];

    buildPhase = ''
      (echo [; okolors ${config.hyprworld.wallpaper} -w 0 -k 1 -l 10,20,30,50,70 | tail -n +2 | sed -e 's/\(.*\)/"\1"/'; echo ]) > ./default.nix
    '';

    installPhase = ''
      mkdir -p $out
      cp ./default.nix $out/
    '';
  });

  stylesheet = lib.strings.concatLines (lib.attrsets.mapAttrsToList (key: value: "\$${key}: #${builtins.elemAt palette value};") {
    dark-bg = 0;
    bg = 1;
    light-bg = 2;

    fg = 4;
    alt-fg = 3;
  });

  ags = pkgs.stdenv.mkDerivation {
    name = "hyprworld_ags";

    src = ./ags;

    nativeBuildInputs = with pkgs; [
      esbuild
      sass
      fd
    ];

    buildPhase = ''
      (echo ${pkgs.writeText "style.scss" stylesheet}; fd ".scss" $src) | awk '{print "@import \"" $1 "\";"}' | sass --scss --stdin | sed -e 's:\\@:@:g' > ./style.css

      cp $src/tsconfig.json .
      esbuild --bundle $src/main.ts --format=esm --outfile=./config.js "--external:resource://*" "--external:gi://*" "--external:file://*"
    '';

    installPhase = ''
      mkdir -p $out/share
      cp ./style.css $out/share/
      cp ./config.js $out/share/
    '';
  };
in
{
  systemd.user.services.ags = import ./service.nix pkgs "${inputs.ags.packages.${pkgs.system}.ags}/bin/ags -b hypr -c ${ags}/share/config.js";
}