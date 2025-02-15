{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkMerge
    types
    ;
in
{
  options.tetrago.sddm = {
    enable = mkEnableOption "SDDM display manager";
    wayland = mkOption {
      type = types.bool;
      default = true;
    };

    package = mkOption {
      type = with types; nullOr package;
      description = "Optional sddm package override";
      default = null;
      example = pkgs.kdePackages.sddm;
    };

    theme = mkOption {
      type =
        with types;
        nullOr (submodule {
          options = {
            name = mkOption {
              type = str;
            };
            package = mkOption {
              type = nullOr package;
              default = null;
            };
            extraPackages = mkOption {
              type = listOf package;
              default = [ ];
            };
          };
        });
    };
  };

  config =
    let
      cfg = config.tetrago.sddm;
    in
    mkIf cfg.enable (mkMerge [
      {
        services.displayManager.sddm = {
          enable = true;
          wayland.enable = cfg.wayland;
          package = mkIf (cfg.package != null) cfg.package;
        };
      }
      (mkIf (cfg.theme != null) {
        services.displayManager.sddm = {
          theme = cfg.theme.name;
          extraPackages = cfg.theme.extraPackages;
        };

        environment.systemPackages = mkIf (cfg.theme.package != null) [ cfg.theme.package ];
      })
    ]);
}
