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
      nativeBuildInputs = [ makeWrapper ];

      postBuild = ''
        rm $out/share/applications/rofi.desktop
        rm $out/share/applications/rofi-theme-selector.desktop

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

      polymorph.file = [ "${config.xdg.configHome}/nwg-drawer/drawer.css" ];

      xdg = {
        configFile."nwg-drawer/drawer.css".text = ''
          {{- with .colors -}}

          window {
              background-color: rgba({{ .base00_c }}, 0.95);
              color: #{{ .base05 }};
              border-radius: 8px;
              box-shadow: 0 5px 20px rgba(21, 21, 21, 0.4);
          }

          entry {
              background-color: rgba({{ .base01_c }}, 0.80);
              border-radius: 6px;
              padding: 8px;
              border: 1px solid rgba({{ .base0D_c }}, 0.30);
              box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.2);
              color: #{{ .base05 }};
              caret-color: #{{ .base0E }};
          }

          button, image {
              background: none;
              border: none;
              border-radius: 4px;
              padding: 6px;
              transition: all 0.2s ease;
              color: #{{ .base05 }};
          }

          button:hover {
              background-color: rgba({{ .base01_c }}, 0.70);
          }

          button:active {
              background-color: rgba({{ .base0D_c }}, 0.30);
          }

          #category-button {
              margin: 0 8px 0 8px;
              border-radius: 6px;
              padding: 6px 10px;
              font-weight: 600;
              color: #{{ .base05 }};
          }

          #category-button:hover {
              background-color: rgba({{ .base0B_c }}, 0.20);
              color: #{{ .base0B }};
          }

          #category-button:active {
              background-color: rgba({{ .base0B_c }}, 0.20);
              color: #{{ .base0B }};
          }

          #pinned-box {
              padding-bottom: 12px;
              margin-bottom: 12px;
              border-bottom: 1px solid rgba({{ .base0D_c }}, 0.50);
          }

          #files-box {
              padding: 12px;
              border-radius: 8px;
              background-color: rgba({{ .base01_c }}, 0.50);
              box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
              margin: 8px 0;
          }

          #math-label {
              font-weight: bold;
              font-size: 16px;
              color: #{{ .base0C }};
          }

          scrollbar {
              background-color: transparent;
              border-radius: 6px;
          }

          scrollbar slider {
              background-color: rgba({{ .base0D_c }}, 0.40);
              border-radius: 6px;
          }

          scrollbar slider:hover {
              background-color: rgba({{ .base0F_c }}, 0.60);
          }

          label {
              color: #{{ .base05 }};
              font-weight: 500;
          }

          .selected, :selected {
              background-color: rgba({{ .base0E_c }}, 0.30);
              color: #{{ .base0E }};
          }

          .success {
              color: #{{ .base0B }};
          }

          .warning {
              color: #{{ .base09 }};
          }

          .error {
              color: #{{ .base08 }};
          }

          {{- end -}}
        '';

        dataFile = {
          "rofi/themes/dark.rasi".source = "${themes}/themes/spotlight-dark.rasi";
          "rofi/themes/light.rasi".source = "${themes}/themes/spotlight.rasi";
        };
      };
    };
}
