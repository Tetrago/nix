{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  package =
    with pkgs;
    symlinkJoin {
      name = "rofi";
      paths = [ rofi ];
      nativeBuildInputs = [ makeWrapper ];

      postBuild = ''
        rm $out/share/applications/rofi.desktop
        rm $out/share/applications/rofi-theme-selector.desktop
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

      polymorph.file = [
        "${config.xdg.configHome}/nwg-drawer/drawer.css"
        "${config.xdg.configHome}/rofi/config.rasi"
      ];

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

        configFile."rofi/config.rasi".text = ''
          configuration {
            display-drun: "";
            drun-display-format: "{icon} {name}";
            font: "{{ .font.name }} Regular 10";
            modi: "window,run,drun";
            show-icons: true;
          }

          @theme "/dev/null"

          * {
            bg: #{{ .colors.base07 }};
            bg-alt: #{{ .colors.base0D }};
            bg-selected: #{{ .colors.base0D }};
            fg: #{{ .colors.base07 }};
            fg-alt: #{{ .colors.base00 }};
            
            border: 0;
            margin: 0;
            padding: 0;
            spacing: 0;
          }

          window {
            width: 27%;
            background-color: @bg;
            location: north;
            anchor: center;
            y-offset: 13px;
            border-radius: 15px;
            opacity: 1;
          }

          element {
            padding: 8 12;
            background-color: transparent;
            text-color: @fg-alt;
          }

          element selected {
            text-color: @fg;
            background-color: @bg-selected;
          }

          element-text {
            background-color: transparent;
            text-color: inherit;
            vertical-align: 0.5;
          }

          element-icon {
            size: 14;
            padding: 0 10 0 0;
            background-color: transparent;
          }

          entry {
            padding: 12;
            background-color: @bg-alt;
            text-color: @fg;
          }

          inputbar {
            children: [prompt, entry];
            background-color: @bg;
          }

          listview {
            background-color: @bg;
            columns: 1;
            lines: 8;
          }

          mainbox {
            children: [inputbar, listview];
            background-color: @bg;
          }

          prompt {
            enabled: true;
            padding: 12 0 0 12;
            background-color: @bg-alt;
            text-color: @fg;
          }
        '';
      };
    };
}
