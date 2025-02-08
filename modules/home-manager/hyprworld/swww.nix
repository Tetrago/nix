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
    mkOption
    types
    getExe
    ;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.strings) concatStringsSep;
in
{
  options.hyprworld.swww = {
    package = mkOption {
      type = types.package;
      default = pkgs.swww;
    };
  };

  config =
    let
      inherit (pkgs) writeShellScript;

      cfg = config.hyprworld;
      swww = getExe cfg.swww.package;

      set-wallpaper = writeShellScript "update-wallpaper" ''
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

      set-dark-wallpaper = writeShellScript "set-dark-mode" ''
        ${swww} img ${cfg.wallpaper.dark} ${transitions}
      '';

      set-light-wallpaper = writeShellScript "set-light-mode" ''
        ${swww} img ${cfg.wallpaper.light} ${transitions}
      '';
    in
    mkMerge [
      {
        systemd.user.services.swww = {
          Unit = {
            ConditionEnvironment = "WAYLAND_DISPLAY";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session-pre.target" ];
          };

          Service = {
            ExecStart = "${cfg.swww.package}/bin/swww-daemon";
            Restart = "on-failure";
          };

          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      }
      (mkIf (isPath cfg.wallpaper) {
        systemd.user.services.swww.Service.ExecStartPost = "${swww} img ${cfg.wallpaper}";
      })
      (mkIf (!(isPath cfg.wallpaper)) {
        systemd.user.services.swww.Service.ExecStartPost = "${set-wallpaper}";

        xdg.dataFile = {
          "dark-mode.d/update-wallpaper".source = set-dark-wallpaper;
          "light-mode.d/update-wallpaper".source = set-light-wallpaper;
        };
      })
    ];
}
