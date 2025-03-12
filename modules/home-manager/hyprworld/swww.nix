{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) isPath;
  inherit (lib)
    mkMerge
    mkIf
    mkPackageOption
    mkOption
    types
    getExe
    ;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.strings) concatStringsSep;
in
{
  options.hyprworld = {
    wallpaper = mkOption {
      type =
        with types;
        either path (submodule {
          options = {
            dark = mkOption {
              type = path;
            };
            light = mkOption {
              type = path;
            };
            transition = mkOption {
              type = attrsOf anything;
              default = { };
            };
          };
        });
      description = "Path to wallpaper(s).";
    };

    swww = {
      package = mkPackageOption pkgs "swww" {
        default = [ "swww" ];
      };
    };
  };

  config =
    let
      inherit (pkgs) writeShellScript;

      cfg = config.hyprworld;
      swww = getExe cfg.swww.package;

      setWallpaper = writeShellScript "update-wallpaper" ''
        mode="$(darkman get)"
        dark="${cfg.wallpaper.dark}"
        light="${cfg.wallpaper.light}"
        ${swww} img ''${!mode} --transition-type none
      '';

      transitions = concatStringsSep " " (
        mapAttrsToList (k: v: "--transition-${k} ${toString v}") (
          { type = "wave"; } // cfg.wallpaper.transition
        )
      );

      setDarkWallpaper = writeShellScript "set-dark-mode" ''
        ${swww} img ${cfg.wallpaper.dark} ${transitions}
      '';

      setLightWallpaper = writeShellScript "set-light-mode" ''
        ${swww} img ${cfg.wallpaper.light} ${transitions}
      '';
    in
    mkIf cfg.enable (mkMerge [
      {
        systemd.user.services.swww = {
          Unit = {
            ConditionEnvironment = "WAYLAND_DISPLAY";
            PartOf = [ config.wayland.systemd.target ];
            After = [ config.wayland.systemd.target ];
          };

          Service = {
            ExecStart = "${cfg.swww.package}/bin/swww-daemon";
            Restart = "on-failure";
            RestartSec = "10";
          };

          Install = {
            WantedBy = [ config.wayland.systemd.target ];
          };
        };
      }
      (mkIf (isPath cfg.wallpaper) {
        systemd.user.services.swww.Service.ExecStartPost = "${swww} img ${cfg.wallpaper}";
      })
      (mkIf (!(isPath cfg.wallpaper)) {
        systemd.user.services.swww.Service.ExecStartPost = "${setWallpaper}";

        polymorph.morph = {
          dark.extraScripts = setDarkWallpaper;
          light.extraScripts = setLightWallpaper;
        };
      })
    ]);
}
