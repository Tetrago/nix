{
  config,
  inputs,
  lib,
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
in
{
  imports = [
    inputs.hyprland.homeManagerModules.default
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
            (mkExec "E" "nautilus --new-window")
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
            {
              super = false;
              trigger = "XF86PowerOff";
              action.exec = "hyprworld-shutdown";
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

        environment = {
          GDK_SCALE = mkIf (cfg.globalScale != null) cfg.globalScale;
          QT_QPA_PLATFORMTHEME = "gtk3";
        };

        windowRules = [
          {
            class = "steam_app_\\d+";
            rules = [
              "rounding"
              "noshadow"
              "noborder"
            ];
          }
          {
            title = "File Operation Progress";
            rules = [
              "float"
              "size 400 100"
              "center"
            ];
          }
          {
            title = "Properties";
            rules = [
              "float"
              "size 400 600"
              "center"
            ];
          }
          {
            title = "Bulk Rename";
            rules = [
              "float"
              "size 800 600"
              "center"
            ];
          }
          {
            class = "xdg-desktop-portal-gtk";
            rules = [
              "float"
              "size 70% 70%"
            ];
          }
        ];

        workspaceRules = [
          {
            workspace = "special:scratchpad";
            rules = "gapsout:100";
          }
        ];
      };

      wayland.windowManager.hyprland = {
        settings = {
          bezier = [
            "wkr, 0.4, 0.0, 0.2, 1.0"
            "wnd, 0.16, 1, 0.3, 1"
          ];

          animation = [
            "fade, 1, 4, default"
            "fadeSwitch, 1, 5, default"
            "fadeShadow, 1, 5, default"
            "fadeDim, 1, 5, default"
            "windows, 1, 6, wnd, slide"
            "workspaces, 1, 6, wkr, slide"
            "specialWorkspace, 1, 6, wkr, slidevert"
          ];

          exec-once = [
            "wl-paste --type text --watch ${getExe pkgs.cliphist} store"
            "wl-paste --type image --watch ${getExe pkgs.cliphist} store"
          ];

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
            layout = "master";
          };

          gestures = {
            workspace_swipe = true;
            workspace_swipe_create_new = false;
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
              color = "rgba(1a1a1aee)";
              range = 4;
              render_power = 3;
            };
          };

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            new_window_takes_over_fullscreen = 2;
            middle_click_paste = false;
            vfr = true;
          };

          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };

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
      };
    };
}
