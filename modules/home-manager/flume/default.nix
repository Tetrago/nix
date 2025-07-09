{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;
  inherit (lib.strings) concatLines concatStringsSep;
in
{
  imports = [
    ./bar.nix
    ./darkman.nix
    ./idle.nix
    ./launcher.nix
    ./osd.nix
    ./portal.nix
    ./wallpaper.nix
  ];

  options.flume = {
    enable = mkEnableOption "flume desktop environment.";
    niri.package = mkPackageOption pkgs "niri" { };

    spawn = mkOption {
      type = with types; listOf (coercedTo str (x: [ x ]) (listOf str));
      example = [
        [
          "wl-paste"
          "--type"
          "--text"
        ]
      ];
      default = [ ];
    };
  };

  config =
    let
      cfg = config.flume;
    in
    mkIf cfg.enable {
      home = {
        packages = with pkgs; [
          cfg.niri.package
          xwayland-satellite
          wl-clipboard
        ];

        sessionVariables = {
          SSH_AUTH_SOCK = "/run/user/%u/keyring/ssh";
        };
      };

      flume.spawn =
        map
          (type: [
            "wl-paste"
            "--type"
            type
            "--watch"
            "${getExe pkgs.cliphist}"
            "store"
          ])
          [
            "text"
            "image"
          ]
        ++ [
          [
            (getExe pkgs.brightnessctl)
            "--device=kbd_backlight"
            "set"
            "1"
          ]
          [
            (getExe pkgs.gtklock)
          ]
        ];

      xdg = {
        enable = true;
        configFile."niri/config.kdl".text =
          let
            osd = "${pkgs.swayosd}/bin/swayosd-client";
          in
          ''
            ${concatLines (
              map (x: "spawn-at-startup ${concatStringsSep " " (map (x: ''"${x}"'') x)}") cfg.spawn
            )}

            prefer-no-csd

            screenshot-path "~/Pictures/Screenshots/%Y-%m-%d %H-%M-%S.png"

            environment  {
              QT_QPA_PLATFORM "wayland;xcb"
              QT_WAYLAND_DISABLE_WINDOWDECORATION "1"
              _JAVA_AWT_WM_NONREPARENTING "1"
              GTK_BACKEND "wayland"
              GTK_USE_PORTAL "1"
              NIXOS_OZONE_WL "1"
            }

            hotkey-overlay {
              skip-at-startup
            }

            gestures {
              hot-corners {
                off
              }
            }

            clipboard {
              disable-primary
            }

            input {
              keyboard {
                xkb {
                  options "ctrl:nocaps"
                }
              }

              touchpad {
                tap
                natural-scroll
                dwt
              }

              warp-mouse-to-focus
              focus-follows-mouse max-scroll-amount="95%"
            }

            layout {
              background-color "transparent"
              gaps 8

              tab-indicator {
                hide-when-single-tab
                place-within-column
              }
            }

            window-rule {
              geometry-corner-radius 12
              clip-to-geometry true

              focus-ring {
                width 1
              }
            }

            binds {
              Mod+Return { spawn "ghostty"; }
              Mod+N { spawn "firefox"; }
              Mod+E { spawn "nautilus" "--new-window"; }
              Mod+Space { spawn "sherlock"; }

              Mod+Escape { spawn "darkman" "toggle"; }

              Mod+Minus { set-column-width "-10%"; }
              Mod+Equal { set-column-width "+10%"; }

              Mod+R { switch-preset-column-width; }
              Mod+Shift+R { switch-preset-window-height; }
              Mod+Ctrl+R { reset-window-height; }

              Mod+F { toggle-window-floating; }

              Mod+W { close-window; }

              Mod+Shift+Space { maximize-column; }
              Mod+Shift+F { fullscreen-window; }

              Mod+P { expand-column-to-available-width; }
              Mod+T { toggle-column-tabbed-display; }

              Mod+Tab { toggle-overview; }

              Mod+Shift+S { screenshot; }
              Print { screenshot-screen; }
              Alt+Print { screenshot-window; }

              Mod+H { focus-column-left; }
              Mod+J { focus-window-down; }
              Mod+K { focus-window-up; }
              Mod+L { focus-column-right; }
              Mod+Left { focus-column-left; }
              Mod+Down { focus-window-down; }
              Mod+Up { focus-window-up; }
              Mod+Right { focus-column-right; }

              Mod+Shift+H { move-column-left; }
              Mod+Shift+J { move-window-down; }
              Mod+Shift+K { move-window-up; }
              Mod+Shift+L { move-column-right; }
              Mod+Shift+Left { move-column-left; }
              Mod+Shift+Down { move-window-down; }
              Mod+Shift+Up { move-window-up; }
              Mod+Shift+Right { move-column-right; }

              Mod+1 { focus-workspace 1; }
              Mod+2 { focus-workspace 2; }
              Mod+3 { focus-workspace 3; }
              Mod+4 { focus-workspace 4; }
              Mod+5 { focus-workspace 5; }
              Mod+6 { focus-workspace 6; }
              Mod+7 { focus-workspace 7; }
              Mod+8 { focus-workspace 8; }
              Mod+9 { focus-workspace 9; }
              Mod+0 { focus-workspace 10; }

              Mod+Shift+1 { move-column-to-workspace 1; }
              Mod+Shift+2 { move-column-to-workspace 2; }
              Mod+Shift+3 { move-column-to-workspace 3; }
              Mod+Shift+4 { move-column-to-workspace 4; }
              Mod+Shift+5 { move-column-to-workspace 5; }
              Mod+Shift+6 { move-column-to-workspace 6; }
              Mod+Shift+7 { move-column-to-workspace 7; }
              Mod+Shift+8 { move-column-to-workspace 8; }
              Mod+Shift+9 { move-column-to-workspace 9; }
              Mod+Shift+0 { move-column-to-workspace 10; }

              Mod+Comma { consume-or-expel-window-left; }
              Mod+Period { consume-or-expel-window-right; }

              XF86AudioRaiseVolume { spawn "${osd}" "--output-volume" "raise"; }
              XF86AudioLowerVolume { spawn "${osd}" "--output-volume" "lower"; }
              XF86AudioMute { spawn "${osd}" "--output-volume" "mute-toggle"; }
              XF86AudioMicMute { spawn "${osd}" "--input-volume" "mute-toggle"; }

              XF86MonBrightnessUp { spawn "${osd}" "--brightness" "raise"; }
              XF86MonBrightnessDown { spawn "${osd}" "--brightness" "lower"; }
            }

            output "eDP-1" {
              mode "2560x1664@60"
              scale 1.5
            }
          '';
      };

      dconf = {
        enable = true;
        settings."org/gnome/location".enabled = true;
      };

      systemd.user.services = {
        gnome-keyring = {
          Unit = {
            PartOf = [ "graphical-session-pre.target" ];
          };

          Service = {
            ExecStart = "/run/wrappers/bin/gnome-keyring-daemon --start --foreground --components=secrets,ssh";
            Restart = "on-abort";
          };

          Install = {
            WantedBy = [ "graphical-session-pre.target" ];
          };
        };

        polkit-gnome-authentication-agent-1 = {
          Unit = {
            Wants = [ config.wayland.systemd.target ];
            After = [ config.wayland.systemd.target ];
          };

          Service = {
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };

          Install = {
            WantedBy = [ config.wayland.systemd.target ];
          };
        };
      };
    };
}
