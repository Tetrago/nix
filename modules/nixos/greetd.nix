{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.strings) concatStringsSep optionalString;
  inherit (lib.attrsets) genAttrs filterAttrs mapAttrsToList;
in
{
  options.tetrago.greetd = {
    enable = mkEnableOption "greetd";
    theme = mkOption {
      type =
        with types;
        nullOr (submodule {
          options =
            genAttrs
              [
                "text"
                "time"
                "container"
                "border"
                "title"
                "greet"
                "prompt"
                "input"
                "action"
                "button"
              ]
              (
                _:
                mkOption {
                  type = nullOr (enum [
                    "black"
                    "red"
                    "green"
                    "yellow"
                    "blue"
                    "magenta"
                    "cyan"
                    "gray"
                    "darkgray"
                    "lightred"
                    "lightgreen"
                    "lightyellow"
                    "lightblue"
                    "lightmagenta"
                    "lightcyan"
                    "white"
                  ]);
                  default = null;
                }
              );
        });
      default = null;
    };
  };

  config =
    let
      cfg = config.tetrago.greetd;

      sessions = concatStringsSep ":" (
        map (session: "${session}/share/xsessions") config.services.displayManager.sessionPackages
      );

      theme =
        let
          inherit (config.tetrago.greetd) theme;
        in
        optionalString (theme != null) (
          "--theme '"
          + (concatStringsSep ";" (mapAttrsToList (k: v: "${k}=${v}") (filterAttrs (_: v: v != null) theme)))
          + "'"
        );
    in
    mkIf cfg.enable {
      services.greetd = {
        enable = true;
        restart = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${sessions} ${theme}";
            user = "greeter";
          };
        };
      };
    };
}
