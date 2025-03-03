{
  config,
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}:

let
  inherit (builtins) substring;
  inherit (lib)
    getExe
    mkIf
    mkOption
    range
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
  imports = [
    inputs.hyprland.homeManagerModules.default
    outputs.homeManagerModules.nixland
  ];

  options.hyprworld = {
    extraVolumeKeys = mkOption {
      type = types.bool;
      description = "binds F10, F11, and F12 to mute, increase volume, and decrease volume respectively.";
      default = false;
    };

    globalScale = mkOption {
      type = with types; nullOr numbers.positive;
      description = "global scale setting; used for GDK_SCALE.";
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

      nixland = {
        enable = true;
        binds =
          with pkgs;
          let
            mkExec = trigger: exec: {
              inherit trigger;
              action = { inherit exec; };
            };
          in
          [
            (mkExec "Return" "ghostty")
            (mkExec "E" "nautilus")
            (mkExec "L" "loginctl lock-session")
            (mkExec "Space" "rofi -show drun -show-icons -sorting-method fzf -scroll-method 1")
            (mkExec "O" (getExe inputs.hyprmag.packages.${stdenv.hostPlatform.system}.default))
            {
              shift = true;
              trigger = "C";
              action.exec = "pidof hyprpicker || ${getExe hyprpicker} -a";
            }
            {
              trigger = "W";
              action = "killactive";
            }
            {
              shift = true;
              trigger = "V";
              action.exec = "${getExe cliphist} wipe";
            }
            {
              trigger = "V";
              action.exec =
                let
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
                in
                "rofi -modi clipboard:${cliphist-rofi-img} -show-icons -sorting-method fzf -scroll-method 1 -show clipboard";
            }
            {
              trigger = "F";
              action = "togglefloating";
            }
            {
              trigger = "Escape";
              action = "fullscreen";
            }
            {
              shift = true;
              trigger = "Escape";
              action.exec = "darkman toggle";
            }
            {
              super = false;
              trigger = "Print";
              action.exec = ''pidof slurp || ${getExe grim} -g "$(${getExe slurp} -o -r)" - | ${getExe swappy} -f -'';
            }
            {
              super = false;
              alt = true;
              trigger = "Print";
              action.exec =
                let
                  find = pkgs.writeShellScript "find-windows" ''hyprctl clients -j | ${getExe jq} -r ".[]" | ${getExe jq} -r ".at,.size" | ${getExe jq} -s "add" | ${getExe jq} '_nwise(4)' | ${getExe jq} -r '"\(.[0]),\(.[1]) \(.[2])x\(.[3])"' | ${getExe slurp} -r'';
                in
                ''pidof slurp || ${getExe grim} -g "$(${find})" - | ${getExe swappy} -f -'';
            }
            {
              shift = true;
              trigger = "S";
              action.exec = ''pidof slurp || ${getExe grim} -g "$(${getExe slurp})" - | ${getExe swappy} -f -'';
            }
            {
              shift = true;
              trigger = "Z";
              action.movetoworkspace = "special:scratchpad";
            }
            {
              trigger = "Z";
              action.togglespecialworkspace = "scratchpad";
            }
            {
              shift = true;
              trigger = "Space";
              action.fullscreen = "1";
            }
            {
              trigger = "Tab";
              action = "overview:toggle";
            }
            {
              trigger = "I";
              action = "invertactivewindow";
            }
            {
              super = false;
              alt = true;
              trigger = "Tab";
              action.cyclenext = "floating";
            }
            {
              super = false;
              alt = true;
              trigger = "Tab";
              action = "bringactivetotop";
            }
            {
              trigger = "M";
              action.layoutmsg = "swapwithmaster";
            }
            {
              flags = "mouse";
              trigger = "mouse:272";
              action = "movewindow";
            }
            {
              flags = "mouse";
              trigger = "mouse:273";
              action = "resizewindow";
            }
            {
              flags = "repeat";
              super = false;
              trigger = "XF86AudioMute";
              action.exec = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            }
            {
              flags = "repeat";
              super = false;
              trigger = "XF86AudioRaiseVolume";
              action.exec = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
            }
            {
              flags = "repeat";
              super = false;
              trigger = "XF86AudioLowerVolume";
              action.exec = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            }
            {
              flags = "repeat";
              super = false;
              ctrl = true;
              trigger = "F10";
              action.exec = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            }
            {
              flags = "repeat";
              super = false;
              ctrl = true;
              trigger = "F12";
              action.exec = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
            }
            {
              flags = "repeat";
              super = false;
              ctrl = true;
              trigger = "F11";
              action.exec = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            }
          ]
          ++ map (v: v // { super = false; }) [
            (mkExec "XF86MonBrightnessUp" "${getExe brightnessctl} set +10%")
            (mkExec "XF86MonBrightnessDown" "${getExe brightnessctl} set 10%-")
            (mkExec "XF86AudioPlay" "${getExe playerctl} play-pause")
            (mkExec "XF86AudioStop" "${getExe playerctl} stop")
            (mkExec "XF86AudioPrev" "${getExe playerctl} previous")
            (mkExec "XF86AudioNext" "${getExe playerctl} next")
          ]
          ++ map (v: {
            trigger = if v == 10 then 0 else v;
            action.workspace = v;
          }) (range 1 10)
          ++ map (v: {
            shift = true;
            trigger = if v == 10 then 0 else v;
            action.movetoworkspace = v;
          }) (range 1 10)
          ++
            map
              (dir: {
                trigger = dir;
                action.movefocus = substring 0 1 dir;
              })
              [
                "left"
                "right"
                "up"
                "down"
              ];

        windowrules = [
          {
            class = "^(steam_app_\\d+)$";
            rules = [
              "rounding"
              "noshadow"
              "noborder"
            ];
          }
          {
            title = "^(File Operation Progress)$";
            rules = [
              "float"
              "size 400 100"
              "center"
            ];
          }
          {
            title = "^(Properties)$";
            rules = [
              "float"
              "size 400 600"
              "center"
            ];
          }
          {
            title = "^(Bulk Rename)$";
            rules = [
              "float"
              "size 800 600"
              "center"
            ];
          }
          {
            class = "^(xdg-desktop-portal-gtk)$";
            rules = [
              "float"
              "size 70% 70%"
            ];
          }
        ];
      };

      wayland.windowManager.hyprland = {
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
            blur = {
              enabled = true;
              size = 3;
              passes = 1;
            };
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
          workspace = workspaces ++ [
            "special:scratchpad, gapsout:100"
          ];

          layerrule = [
            "noanim,hyprpicker"
            "noanim,selection"
          ];

          "plugin:overview:showNewWorkspace" = false;
          "plugin:dynamic-cursors".mode = "none";
        };

        plugins =
          let
            inherit (pkgs.stdenv.hostPlatform) system;
          in
          with inputs;
          [
            hyprspace.packages.${system}.Hyprspace
            hypr-darkwindow.packages.${system}.Hypr-DarkWindow
            hypr-dynamic-cursors.packages.${system}.hypr-dynamic-cursors
          ];

        systemd = {
          enable = true;
          variables = [ "--all" ];
        };
      };
    };
}
