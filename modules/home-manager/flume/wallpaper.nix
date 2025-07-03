{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) isPath;
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;
in
{
  options.flume = {
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
          };
        });
      description = "Path to wallpaper(s).";
    };
  };

  config =
    let
      cfg = config.flume;
    in
    mkIf cfg.enable {
      xdg = {
        enable = true;
        dataFile."flume/wallpaper".text =
          if isPath cfg.wallpaper then cfg.wallpaper else "{{ .wallpaper }}";
      };

      polymorph = {
        file = [ "${config.xdg.dataHome}/flume/wallpaper" ];

        morph = mkIf (!(isPath cfg.wallpaper)) {
          # FIX: common extraScripts are broken in polymorph
          dark.extraScripts = "niri msg action do-screen-transition && systemctl --user restart swaybg.service";
          light.extraScripts = "niri msg action do-screen-transition && systemctl --user restart swaybg.service";

          dark.context.wallpaper = cfg.wallpaper.dark;
          light.context.wallpaper = cfg.wallpaper.light;
        };
      };

      systemd.user.services.swaybg = {
        Unit = {
          PartOf = [ config.wayland.systemd.target ];
          After = [ config.wayland.systemd.target ];
          Requisite = [ config.wayland.systemd.target ];
        };

        Service = {
          ExecStart = pkgs.writeShellScript "swaybg-flume" ''
            wallpaper="$(cat "${config.xdg.dataHome}/flume/wallpaper")"
            exec ${lib.getExe pkgs.swaybg} -m fill -i "$wallpaper"
          '';
          Restart = "on-failure";
        };

        Install = {
          WantedBy = [ "niri.service" ];
        };
      };
    };
}
