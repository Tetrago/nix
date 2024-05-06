{ config, inputs, lib, pkgs, ... }:

let
  stylesheet = lib.strings.concatLines (lib.attrsets.mapAttrsToList (key: value: "\$${key}: #${config.colorScheme.palette.${value}};") {
    bg = "base00";
    alt-bg = "base01";
    selected-bg = "base02";

    fg = "base05";
    alt-fg = "base04";

    highlight = "base0D";
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