{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) isString;
  inherit (lib)
    mkMerge
    mkIf
    mkOption
    types
    getExe
    ;
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
      cfg = config.hyprworld;
      swww = getExe cfg.swww.package;

      set-wallpaper = pkgs.writeShellScript "update-wallpaper" ''
        mode="$(darkman get)"

        if [ "$mode" = "dark" ]; then
          ${swww} img ${cfg.wallpaper.dark}
        elif [ "$mode" = "light" ]; then
          ${swww} img ${cfg.wallpaper.light}
        fi
      '';

      set-dark-wallpaper = pkgs.writeShellScript "set-dark-mode" ''
        ${swww} img ${cfg.wallpaper.dark} --transition-type any --transition-fps 60 --transition-step 10
      '';

      set-light-wallpaper = pkgs.writeShellScript "set-light-mode" ''
        ${swww} img ${cfg.wallpaper.light} --transition-type any --transition-fps 60 --transition-step 10
      '';
    in
    mkMerge [
      ({
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
      })
      (mkIf (isString cfg.wallpaper) {
        systemd.user.services.swww.Service.ExecStartPost = "${swww} img ${cfg.wallpaper}";
      })
      (mkIf (!(isString cfg.wallpaper)) {
        systemd.user.services.swww.Service.ExecStartPost = "${set-wallpaper}";

        xdg.dataFile = {
          "dark-mode.d/update-wallpaper".source = set-dark-wallpaper;
          "light-mode.d/update-wallpaper".source = set-light-wallpaper;
        };
      })
    ];
}
