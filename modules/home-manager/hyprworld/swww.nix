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

        if [ "$mode" = "dark" ]; then
          ${swww} img ${cfg.wallpaper.dark}
        elif [ "$mode" = "light" ]; then
          ${swww} img ${cfg.wallpaper.light}
        fi
      '';

      get-transition-pos =
        let
          jq = getExe pkgs.jq;
        in
        writeShellScript "get-transition-pos" ''
          monitor=$(hyprctl monitors -j | ${jq} ".[] | select(.id == $(hyprctl activeworkspace -j | ${jq} .monitorID)) | {x, y, height}")
          mx=$(echo "$monitor" | ${jq} .x)
          my=$(echo "$monitor" | ${jq} .y)
          height=$(echo "$monitor" | ${jq} .height)

          cursor=$(hyprctl cursorpos -j)
          cx=$(echo "$cursor" | ${jq} .x)
          cy=$(echo "$cursor" | ${jq} .y)

          x=$((cx - mx))
          y=$((height - (cy - my)))

          echo "$x,$y"
        '';

      transitions = concatStringsSep " " (
        mapAttrsToList (k: v: "--transition-${k} ${toString v}") cfg.wallpaper.transition
      );

      set-dark-wallpaper = writeShellScript "set-dark-mode" ''
        ${swww} img ${cfg.wallpaper.dark} --transition-type outer --transition-pos $(${get-transition-pos}) ${transitions}
      '';

      set-light-wallpaper = writeShellScript "set-light-mode" ''
        ${swww} img ${cfg.wallpaper.light} --transition-type grow --transition-pos $(${get-transition-pos}) ${transitions}
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
