{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    getExe
    mkOption
    types
    ;
  inherit (lib.strings) optionalString;
  inherit (lib.lists) flatten optional optionals;

  monitorToString =
    m:
    if !m.enable then
      "${m.name},disable"
    else
      let
        refreshRate = optionalString (
          m.resolution != null && m.resolution.refreshRate != null
        ) "@${toString m.resolution.refreshRate}";
        resolution =
          if m.resolution == null then
            "preferred"
          else
            "${toString m.resolution.width}x${toString m.resolution.height}${refreshRate}";
        position =
          if m.position == null then "auto" else "${toString m.position.x}x${toString m.position.y}";
        scale = if m.scale == null then "auto" else "${toString m.scale}";
      in
      "${m.name},${resolution},${position},${scale}";

  monitorToWorkspace =
    m: optional (m.workspace != null) "${toString m.workspace},monitor:${m.name},default:true";

  monitors = optionals (
    config.hyprworld.monitors != null && config.hyprworld.additionalMonitors == null
  ) (map monitorToString config.hyprworld.monitors);

  workspaces = optionals (
    config.hyprworld.monitors != null && config.hyprworld.additionalMonitors == null
  ) (flatten (map monitorToWorkspace config.hyprworld.monitors));
in
{
  imports = [ inputs.hyprland.homeManagerModules.default ];

  options.hyprworld = {
    extraVolumeKeys = mkOption {
      type = types.bool;
      description = "binds F10, F11, and F12 to mute, increase volume, and decrease volume respectively";
      default = false;
    };

    globalScale = mkOption {
      type = with types; nullOr numbers.positive;
      description = "global scale setting; used for GDK_SCALE";
      default = null;
    };
  };

  config =
    let
      cfg = config.hyprworld;
    in
    mkIf cfg.enable {
      home.packages = with pkgs; [
        wl-clipboard
      ];

      wayland.windowManager.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        xwayland.enable = true;

        settings = {
          exec-once = [
            "wl-paste --type text --watch ${getExe pkgs.cliphist} store"
            "wl-paste --type image --watch ${getExe pkgs.cliphist} store"
          ];

          env =
            [
              "XDG_SESSION_DESKTOP,Hyprland"
              "QT_QPA_PLATFORM,wayland;xcb"
              "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
              "_JAVA_AWT_WM_NONREPARENTING,1"
              "GTK_BACKEND,wayland"
              "GTK_USE_PORTAL,1"
              "NIXOS_OZONE_WL,1"
            ]
            ++ optional (
              config.hyprworld.globalScale != null
            ) "GDK_SCALE,${toString config.hyprworld.globalScale}";

          debug = {
            disable_logs = false;
          };

          master = {
            new_status = "master";
            mfact = 0.5;
          };

          xwayland = {
            force_zero_scaling = true;
          };

          input = {
            follow_mouse = true;
            touchpad.natural_scroll = true;
            numlock_by_default = true;
            kb_options = "ctrl:nocaps";
          };

          general = {
            gaps_in = 5;
            gaps_out = 5;
            border_size = 1;
            "col.active_border" = "rgba(eff1f5ee) rgba(bbbfcbee) 45deg";
            "col.inactive_border" = "rgba(4b4e69aa)";
            layout = "master";
          };

          gestures = {
            "workspace_swipe" = true;
            "workspace_swipe_create_new" = false;
          };

          decoration = {
            rounding = 5;
            blur.enabled = true;
            blur.size = 3;
            blur.passes = 1;
            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
              color = "rgba(1a1a1aee)";
            };
          };

          misc = {
            new_window_takes_over_fullscreen = 2;
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            vfr = true;
          };

          monitor = monitors ++ [ ",preferred,auto,1" ];
          workspace = workspaces;

          "$mod" = "SUPER";

          bind =
            let
              ags = getExe inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.ags;
              hyprpicker = getExe pkgs.hyprpicker;
              nautilus = getExe pkgs.nautilus;
              cliphist = getExe pkgs.cliphist;
              cliphist-rofi-img = getExe (
                pkgs.symlinkJoin {
                  name = "cliphist-rofi-img-packaged";
                  paths = [ pkgs.cliphist ];
                  buildInputs = [ pkgs.makeWrapper ];
                  postBuild = ''
                    wrapProgram $out/bin/cliphist-rofi-img \
                      --prefix PATH : ${lib.makeBinPath [ pkgs.cliphist ]}
                  '';
                  meta.mainProgram = "cliphist-rofi-img";
                }
              );
              jq = getExe pkgs.jq;
              brightnessctl = getExe pkgs.brightnessctl;
              playerctl = getExe pkgs.playerctl;
              slurp = getExe pkgs.slurp;
              grim = getExe pkgs.grim;
              swappy = getExe pkgs.swappy;
              find = pkgs.writeShellScriptBin "findWindows" ''hyprctl clients -j | ${jq} -r ".[]" | ${jq} -r ".at,.size" | ${jq} -s "add" | ${jq} '_nwise(4)' | ${jq} -r '"\(.[0]),\(.[1]) \(.[2])x\(.[3])"' | ${slurp} -r'';
            in
            [
              "$mod, Return, exec, ghostty"
              "$mod, C, exec, ${ags} -b hypr -t system_center"
              "$mod SHIFT, C, exec, pidof hyprpicker || ${hyprpicker} -a"
              "$mod, W, killactive"
              "$mod, E, exec, ${nautilus}"
              "$mod, L, exec, loginctl lock-session"
              "$mod SHIFT, V, exec, ${cliphist} wipe"
              "$mod, V, exec, rofi -modi clipboard:${cliphist-rofi-img} -show-icons -sorting-method fzf -scroll-method 1 -show clipboard"
              "$mod, F, togglefloating"
              "$mod, Escape, fullscreen"
              "$mod SHIFT, Escape, exec, darkman toggle"
              "$mod, Space, exec, rofi -show drun -show-icons -sorting-method fzf -scroll-method 1"
              '', Print, exec, pidof slurp || ${grim} -g "$(${slurp} -o -r)" - | ${swappy} -f -''
              ''ALT, Print, exec, pidof slurp || ${grim} -g "$(${find}/bin/findWindows)" - | ${swappy} -f -''
              ''$mod SHIFT, S, exec, pidof slurp || ${grim} -g "$(${slurp})" - | ${swappy} -f -''
              "$mod SHIFT, Z, movetoworkspace, special"
              "$mod, Z, togglespecialworkspace"
              "$mod SHIFT, Space, fullscreen, 1"
              "$mod, Tab, overview:toggle"

              "$mod, left, movefocus, l"
              "$mod, right, movefocus, r"
              "$mod, up, movefocus, u"
              "$mod, down, movefocus, d"
              "$mod, M, exec, hyprctl dispatch layoutmsg swapwithmaster"

              "$mod, 1, workspace, 1"
              "$mod, 2, workspace, 2"
              "$mod, 3, workspace, 3"
              "$mod, 4, workspace, 4"
              "$mod, 5, workspace, 5"
              "$mod, 6, workspace, 6"
              "$mod, 7, workspace, 7"
              "$mod, 8, workspace, 8"
              "$mod, 9, workspace, 9"
              "$mod, 0, workspace, 10"

              "$mod SHIFT, 1, movetoworkspace, 1"
              "$mod SHIFT, 2, movetoworkspace, 2"
              "$mod SHIFT, 3, movetoworkspace, 3"
              "$mod SHIFT, 4, movetoworkspace, 4"
              "$mod SHIFT, 5, movetoworkspace, 5"
              "$mod SHIFT, 6, movetoworkspace, 6"
              "$mod SHIFT, 7, movetoworkspace, 7"
              "$mod SHIFT, 8, movetoworkspace, 8"
              "$mod SHIFT, 9, movetoworkspace, 9"
              "$mod SHIFT, 0, movetoworkspace, 10"

              ", XF86MonBrightnessUp, exec, ${brightnessctl} set +10%"
              ", XF86MonBrightnessDown, exec, ${brightnessctl} set 10%-"
              ", XF86AudioPlay, exec, ${playerctl} play-pause"
              ", XF86AudioStop, exec, ${playerctl} stop"
              ", XF86AudioPrev, exec, ${playerctl} previous"
              ", XF86AudioNext, exec, ${playerctl} next"
            ];

          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];

          binde = lib.mkMerge [
            ([
              ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
              ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
              ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ])
            (lib.mkIf config.hyprworld.extraVolumeKeys [
              "CTRL, F10, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
              "CTRL, F12, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
              "CTRL, F11, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ])
          ];

          windowrulev2 = [
            "rounding 0,class:^(steam_app_\\d+)$"
            "noshadow,class:^(steam_app_\\d+)$"
            "noborder,class:^(steam_app_\\d+)$"

            "float,title:^(File Operation Progress)$"
            "size 400 100,title:^(File Operation Progress)$"
            "center,title:^(File Operation Progress)$"

            "float,title:^(Properties)$"
            "size 400 600,title:^(Properties)$"
            "center,title:^(Properties)$"

            "float,title:^(Bulk Rename)$"
            "size 800 600,title:^(Bulk Rename)$"
            "center,title:^(Bulk Rename)$"
          ];

          layerrule = [
            "noanim,hyprpicker"
            "noanim,selection"
          ];
        };

        plugins = [
          inputs.hyprspace.packages.${pkgs.stdenv.hostPlatform.system}.Hyprspace
        ];

        systemd = {
          enable = true;
          variables = [ "--all" ];
        };
      };
    };
}
