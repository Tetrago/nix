{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  themes = pkgs.fetchFromGitHub {
    owner = "newmanls";
    repo = "rofi-themes-collection";
    rev = "c2be059e9507785d42fc2077a4c3bc2533760939";
    sha256 = "sha256-pHPhqbRFNhs1Se2x/EhVe8Ggegt7/r9UZRocHlIUZKY=";
  };

  package =
    with pkgs;
    symlinkJoin {
      name = "rofi-wayland";
      paths = [ rofi-wayland ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/rofi \
          --add-flags '-theme $XDG_DATA_HOME/rofi/themes/$(darkman get).rasi'
      '';
    };
in
{
  config =
    let
      cfg = config.hyprworld;
    in
    mkIf cfg.enable {
      programs.rofi = {
        enable = true;
        inherit package;
      };

      xdg.dataFile = {
        "rofi/themes/dark.rasi".source = "${themes}/themes/spotlight-dark.rasi";
        "rofi/themes/light.rasi".source = "${themes}/themes/spotlight.rasi";
      };
    };
}
