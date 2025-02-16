{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins)
    isString
    listToAttrs
    map
    pathExists
    toString
    ;

  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;

  inherit (lib.attrsets)
    mapAttrs
    mapAttrsToList
    optionalAttrs
    recursiveUpdate
    ;

  inherit (lib.lists)
    findFirst
    flatten
    unique
    ;

  inherit (lib.strings) concatLines escape optionalString;

  inherit (pkgs) writeShellScript writeText;
in
{
  options.lemur =
    let
      mkNullable =
        options:
        mkOption {
          type = types.nullOr (
            types.submodule {
              inherit options;
            }
          );
          default = null;
        };

      options = {
        cursorTheme = mkNullable {
          name = mkOption { type = types.str; };
          size = mkOption { type = types.ints.positive; };
        };

        font = mkNullable {
          name = mkOption { type = types.str; };
          size = mkOption { type = types.int.positive; };
        };

        iconTheme = mkNullable {
          name = mkOption { type = types.str; };
        };

        theme = mkNullable {
          name = mkOption { type = types.str; };
        };

        packages = mkOption {
          type = types.listOf types.package;
          description = "Packages required for this variant (themes, icons, cursors, ...)";
          default = [ ];
        };

        scripts = mkOption {
          type = types.lines;
          description = "Scripts to run when activating this variant";
          default = "";
        };
      };
    in
    {
      enable = mkEnableOption "lemur theme engine";

      darkman = {
        enable = mkEnableOption "darkman integration";

        darkVariant = mkOption {
          type = types.str;
          description = "Name of variant to use for dark mode";
          default = "dark";
        };

        lightVariant = mkOption {
          type = types.str;
          description = "Name of variant to use for light mode";
          default = "light";
        };
      };

      default = {
        enable = mkEnableOption "default variant on graphical session startup";

        name = mkOption {
          type = types.str;
          description = "Name of default variant to use. Even when disabled, this variant will be used to ser XCURSOR environment variables";
          default = "default";
        };
      };

      variant = mkOption {
        type = types.attrsOf (types.submodule { inherit options; });
        default = { };
      };

      apply = mkOption {
        type = types.attrsOf types.path;
        internal = true;
      };
    };

  config =
    let
      cfg = config.lemur;

      mapVariant =
        variant:
        let
          hasCursorTheme = variant.cursorTheme != null;
          hasFont = variant.font != null;
          hasIconTheme = variant.iconTheme != null;
          hasTheme = variant.theme != null;

          gtkValues =
            optionalAttrs hasCursorTheme {
              gtk-cursor-theme-name = variant.cursorTheme.name;
              gtk-cursor-theme-size = variant.cursorTheme.size;
            }
            // optionalAttrs hasFont {
              gtk-font-name = "${variant.font.name} ${toString variant.font.size}";
            }
            // optionalAttrs hasIconTheme {
              gtk-icon-theme-name = variant.iconTheme.name;
            }
            // optionalAttrs hasTheme {
              gtk-theme-name = variant.theme.name;
            };

          dconfValues =
            optionalAttrs hasCursorTheme {
              cursor-size = variant.cursorTheme.size;
              cursor-theme = variant.cursorTheme.name;
            }
            // optionalAttrs hasFont {
              font-name = "${variant.font.name} ${toString variant.font.size}";
            }
            // optionalAttrs hasIconTheme {
              icon-theme = variant.iconTheme.name;
            }
            // optionalAttrs hasTheme {
              gtk-theme = variant.theme.name;
            };

          rc =
            let
              format = n: v: "${escape [ "=" ] n} = ${if isString v then ''"${v}"'' else toString v}";
            in
            writeText "gtkrc-2.0" (concatLines (mapAttrsToList format gtkValues));

          ini = writeText "settings.ini" (lib.generators.toINI { } { Settings = gtkValues; });

          dconf =
            let
              write =
                n: v:
                ''dconf write /org/gnome/desktop/interface/${n} "${if isString v then "'${v}'" else toString v}"'';
            in
            writeShellScript "dconf" (concatLines (mapAttrsToList write dconfValues));

          iconsIndex = writeText "index.theme" (
            lib.generators.toINI { } {
              "Icon Theme" = {
                Name = "Default";
                Comment = "Variant Cursor Theme";
                Inherits = variant.cursorTheme.name;
              };
            }
          );
        in
        {
          inherit rc ini dconf;

          activate = writeShellScript "activate" ''
            cp -f ${rc} $HOME/.gtkrc-2.0

            mkdir -p $XDG_CONFIG_HOME/gtk-3.0
            cp -f ${ini} $XDG_CONFIG_HOME/gtk-3.0/settings.ini

            mkdir -p $XDG_CONFIG_HOME/gtk-4.0
            cp -f ${ini} $XDG_CONFIG_HOME/gtk-4.0/settings.ini

            ${dconf}

            ${variant.scripts}

            ${optionalString hasCursorTheme ''
              mkdir -p $HOME/.icons/default
              cp -f ${iconsIndex} $HOME/.icons/default/index.theme

              mkdir -p $XDG_DATA_HOME/.icons/default
              cp -f ${iconsIndex} $XDG_DATA_HOME/.icons/default/index.theme
            ''}
          '';
        };

      mergedVariant =
        if (cfg.variant ? default) then
          mapAttrs (
            n: v:
            if n == "default" then v else recursiveUpdate (removeAttrs cfg.variant.default [ "scripts" ]) v
          ) cfg.variant
        else
          cfg.variant;

      variant = mapAttrs (_: mapVariant) mergedVariant;

      packages = unique (flatten (mapAttrsToList (_: v: v.packages) cfg.variant));

      cursors = unique (
        flatten (
          mapAttrsToList (_: v: if v.cursorTheme != null then [ v.cursorTheme.name ] else [ ]) cfg.variant
        )
      );

      findCursorPackage = cursor: findFirst (x: pathExists "${x}/share/icons/${cursor}") null packages;

      mapCursorsToFiles =
        path:
        listToAttrs (
          map (n: {
            name = "${path}/${n}";
            value =
              let
                package = findCursorPackage n;
              in
              if package != null then
                {
                  source = "${findCursorPackage n}/share/icons/${n}";
                }
              else
                { enable = false; };
          }) cursors
        );
    in
    mkIf cfg.enable {
      assertions = mkMerge [
        [
          {
            assertion = !config.gtk.enable;
            message = "Lemur conflicts with gtk module";
          }
          {
            assertion = isNull config.home.pointerCursor;
            message = "Lemur conflicts with home pointer cursor module";
          }
        ]
        (mkIf cfg.darkman.enable [
          {
            assertion = cfg.variant ? "${cfg.darkman.darkVariant}";
            message = "Dark mode variant missing";
          }
          {
            assertion = cfg.variant ? "${cfg.darkman.lightVariant}";
            message = "Light mode variant missing";
          }
        ])
        (mkIf cfg.default.enable [
          {
            assertion = cfg.variant ? "${cfg.default.name}";
            message = "Default variant does not exist";
          }
        ])
      ];

      home = {
        file = {
          ".gtkrc-2.0".enable = false;
          ".icons/default/index.theme".enable = false;
        } // mapCursorsToFiles ".icons";

        inherit packages;

        sessionVariables =
          mkIf (cfg.variant ? "${cfg.default.name}" && cfg.variant.${cfg.default.name}.cursorTheme != null)
            {
              XCURSOR_PATH = "$XCURSOR_PATH\${XCURSOR_PATH:+:}${config.xdg.dataHome}/icons";
              XCURSOR_SIZE = toString cfg.variant.${cfg.default.name}.cursorTheme.size;
              XCURSOR_THEME = cfg.variant.${cfg.default.name}.cursorTheme.name;
            };
      };

      xdg = {
        enable = true;

        configFile = {
          "gtk-3.0/settings.ini".enable = false;
          "gtk-4.0/settings.ini".enable = false;
        };

        dataFile = {
          "icons/default/index.theme".enable = false;
        } // mapCursorsToFiles "icons";
      };

      systemd.user.services = mkIf cfg.default.enable {
        Unit = {
          ConditionEnvironment = "WAYLAND_DISPLAY";
          PartOf = [ config.wayland.systemd.target ];
          After = [ config.wayland.systemd.target ];
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${cfg.apply.${cfg.default.name}}";
          RemainAfterExit = "no";
        };

        Install = {
          WantedBy = [ config.wayland.systemd.target ];
        };
      };

      lemur.apply = mapAttrs (_: v: v.activate) variant;

      services = mkMerge [
        {
          xsettingsd.enable = true;
        }
        (mkIf cfg.darkman.enable {
          darkman = {
            darkModeScripts.lemur = cfg.apply.${cfg.darkman.darkVariant};
            lightModeScripts.lemur = cfg.apply.${cfg.darkman.lightVariant};
          };
        })
      ];

      qt = {
        enable = true;
        platformTheme.name = "gtk";
      };
    };
}
