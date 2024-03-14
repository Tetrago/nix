{ config, lib, system, pkgs, ... }:

let
  swayncStyle = builtins.readFile(builtins.fetchurl {
    url = "https://github.com/catppuccin/swaync/releases/download/v0.1.2.1/latte.css";
    sha256 = "9050636715700d62a306728b92f94daf21cdab2153d8c6f5391d1029470ead6f";
  });
in
let
  startup = pkgs.writeShellScriptBin "start" ''
    ${pkgs.swaynotificationcenter}/bin/swaync &
    ${pkgs.wl-clipboard}/bin/wl-paste --type text --watch cliphist store &
    ${pkgs.wl-clipboard}/bin/wl-paste --type image --watch cliphist store &
    ${pkgs.udiskie}/bin/udiskie &
    ${pkgs.networkmanagerapplet}/bin/nm-applet &
    ${lib.strings.optionalString config.hyprland.bluetooth.enable "${pkgs.blueman}/bin/blueman-applet &"}
    ${pkgs.waybar}/bin/waybar &
    ${pkgs.hyprpaper}/bin/hyprpaper &
    ${pkgs.hypridle}/bin/hypridle &
  '';
in
{
  options = {
    hyprland.bluetooth.enable = lib.mkEnableOption "enable bluetooth widget";
    hyprland.background.enable = lib.mkEnableOption "enable desktop background";
    hyprland.background.wallpaper = lib.mkOption {
      type = lib.types.str;
      description = "path to wallpaper";
      example = "~/wallpaper.jpg";
    };
  };

  config = {
    home.packages = with pkgs; [
      swaynotificationcenter
      hyprpicker
      hyprpaper
      hypridle
      hyprlock
      pcmanfm
      nwg-bar
      cliphist
      wl-clipboard
      grim
      slurp
      swappy
      brightnessctl
      playerctl
      udiskie
      networkmanagerapplet
      vscode
    ] ++ lib.optionals config.hyprland.bluetooth.enable [ blueman ];

    home.file = {
      ".config/hypr/hyprpaper.conf".text = let path = config.hyprland.background.wallpaper; in ''
        preload = ${path}
	wallpaper = ,${path}
	ipc = off
	splash = off
      '';
      ".config/hypr/hypridle.conf".text = ''
        general {
	  lock_cmd = pidof swaylock || ${pkgs.hyprlock}/bin/hyprlock
	  before_sleep_cmd = loginctl lock-session
	  after_sleep_cmd = hyprctl dispatch dpms on
	}

	listener {
	  timeout = 300
	  on-timeout = loginctl lock-session
	}

	listener {
	  timeout = 380
	  on-timeout = hyprctl dispatch dpms off
	  on-resume = hyprctl dispatch dpms on
	}

	listener {
	  timeout = 1800
	  on-timeout = systemctl suspend
	}
      '';
      ".config/hypr/hyprlock.conf".text = ''
        background = {
	  monitor =
	  color = rgba(25, 20, 20, 1.0)

	  blur_passes = 0
	  blur_size = 7
	  noise = 0.0117
	  contrast = 0.8916
	  brightness = 0.8172
	  vibrancy = 0.1696
	  vibrancy_darkness = 0.0
	}

	input-field {
	  monitor = 
	  size = 200, 50
	  outline_thickness = 3
	  dots_size = 0.33
	  dots_spacing = 0.15
	  dots_center = false
	  dots_rounding = -1
	  outer_color = rgb(151515)
	  inner_color = rgb(200, 200, 200)
	  font_color = rgb(10, 10, 10)
	  fade_on_empty = true
	  fade_timeout = 1000
	  placeholder_text =
	  hide_input = false
	  rounding = -1
	  check_color = rgb(204, 136, 34)
	  fail_color = rgb(204, 34, 34)
	  fail_text =
	  fail_transition = 300

	  position = 0, -20
	  halign = center
	  valign = center
	}
      '';
      ".config/swaync/style.css".text = swayncStyle;
      ".config/nwg-bar/bar.json".text = ''
        [
          {
            "label": "Lock",
            "exec": "loginctl lock-session",
            "icon": "${pkgs.nwg-bar}/share/images/system-lock-screen.svg"
          },
          {
            "label": "Logout",
            "exec": "hyprctl dispatch exit",
            "icon": "${pkgs.nwg-bar}/share/images/system-log-out.svg"
          },
          {
            "label": "Reboot",
            "exec": "systemctl reboot",
            "icon": "${pkgs.nwg-bar}/share/images/system-reboot.svg"
          },
          {
            "label": "Shutdown",
            "exec": "systemctl -i poweroff",
            "icon": "${pkgs.nwg-bar}/share/images/system-shutdown.svg"
          }
        ]
      '';
      ".config/nwg-bar/style.css".text = ''
        window { background-color: rgba (0, 0, 0, 1.0); }
        #outer-box { margin: 0px; }

        #inner-box {
          background-color: rgba (0, 0, 0, 0.85);
          border-radius: 10px;
          border-style: none;
          border-width: 1px;
          border-color: rgba (156, 142, 122, 0.7);
          padding: 5px;
          margin: 5px;
        }

        button, image {
          background: none;
          border: none;
          box-shadow: none;
        }

        button {
          padding-left: 10px;
          padding-right: 10px;
          maring: 5px;
        };

        button:hover {
          background-color: rgba (255, 255, 255, 0.1);
        }
      '';
    };

    programs = {
      alacritty.enable = true;
      wofi = {
        enable = true;
        settings = {
          show = "drun";
          width = 750;
          height = 400;
          always_parse_args = true;
          show_all = false;
          print_command = true;
          insensitive = true;
          prompt = " Hmm, what do you want to run?";
        };
        style = ''
          window {
            margin: 0px;
            border: 1px solid #88c0d0;
            background-color: #2e3440;
          }

          #input {
            margin: 5px;
            border: none;
            color: #d8dee9;
            background-color: #3b4252;
          }

          #inner-box, #outer-box {
            margin: 5px;
            border: none;
            background-color: #2e3440;
          }

          #scroll {
            margin: 0px;
            border: none;
          }

          #text {
            margin: 5px;
            border: none;
            color: #d8dee9;
          }

          #entry:selected {
            background-color: #3b4252;
          }
        '';
      };
      waybar = {
        enable = true;
        settings.mainBar = {
          layer = "top";
          modules-left = [ "hyprland/workspaces" ]; 
          modules-center = [ "clock" ];
          modules-right = [ "cpu" "memory" "battery" "tray" ];
          "hyprland/window".max-length = 50;
          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              active = "";
              empty = "";
              default = "";
              special = "󰻂";
              urgent = "";
            };
          };
          cpu = {
            format = "{icon}";
            format-icons = [ "󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥" ];
          };
          memory = {
            format = "{icon}";
            format-icons = [ "󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥" ];
          };
          battery = {
            format = "{icon}";
            format-icons = [ " " " " " " " " " " ];
            tooltip-format = "{capacity}%";
          };
          calendar = {
            mode = "month";
            format = {
              months = "<span color='#6c6f85'><b>{}</b></span>";
              weekdays = "<span color='#6c6f85'><b>{}</b></span>";
              days = "<span color='#7c7f93'><b>{}</b></span>";
              today = "<span color='#4c4f69'><b>{}</b></span>";
            };
          };
          tray = {
            icon-size = 15;
            spacing = 8;
          };
        };
        style = ''
          * { color: #4c4f69; }
          window#waybar { background: none; }
          tooltip { background-color: alpha(#eff1f5, 0.8); }

          .modules-left, .modules-center, .modules-right {
            background-color: alpha(#eff1f5, 0.8);
            padding: 0 10px;
            margin: 5px 5px 0 5px;
            border-radius: 20px;
          }

          #cpu, #memory, #battery, #tray { padding: 0 10px; }

          #cpu {
            background-color: alpha(#04a5e5, 0.1);
            padding-right: 14px;
          }

          #memory {
            background-color: alpha(#40a02b, 0.1);
            padding-right: 14px;
          }

          #battery {
            background-color: alpha(#e64553, 0.1);
            padding-right: 10px;
          }

          #workspaces button {
            border: none;
            border-radius: 0;
            padding: 0 2px 0 0;
          }

          #workspaces button:hover { background-color: #9ca0b0; }
        '';
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        exec-once = "${startup}/bin/start";
        monitor = map
	  (m:
	    let
	      resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
	      position = "${toString m.x}x${toString m.y}";
	    in
	    "${m.name},${if m.enable then "${resolution},${position},${toString m.dpi}" else "disabled"}"
	  )
	  (system.monitors);
        env = [
          "XCURSOR_SIZE,24"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "QT_QPA_PLATFORM,wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          "_JAVA_AWT_WM_NONREPARENTING,1"
          "GTK_BACKEND,wayland"
          "MOZ_ENABLE_WAYLAND,1"
	  "NIXOS_OZONE_WL,1"
        ];
	master = {
	  new_is_master = "yes";
	  mfact = "0.5";
	};
        input = {
          follow_mouse = "yes";
          touchpad.natural_scroll = "yes";
          numlock_by_default = "yes";
        };
        general = {
          gaps_in = "5";
          gaps_out = "5";
          border_size = "1";
          "col.active_border" = "rgba(eff1f5ee) rgba(bbbfcbee) 45deg";
          "col.inactive_border" = "rgba(4b4e69aa)";
          layout = "master";
        };
        decoration = {
          rounding = "5";
          blur.enabled = "yes";
          blur.size = "3";
          blur.passes = "1";
          drop_shadow = "yes";
          shadow_range = "4";
          shadow_render_power = "3";
          "col.shadow" = "rgba(1a1a1aee)";
        };
        misc = {
          disable_hyprland_logo = "yes";
          disable_splash_rendering = "yes";
          vfr = "yes";
        };
    	"$mod" = "SUPER";
    	bind = [
    	  "$mod, Return, exec, alacritty"
    	  "$mod, C, exec, swaync-client -t -sw"
          "$mod SHIFT, C, exec, hyprpicker -a"
          "$mod, W, killactive"
          "$mod, E, exec, pcmanfm"
          "$mod, Q, exec, nwg-bar"
          "$mod, L, exec, loginctl lock-session"
          "$mod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"
          "$mod, F, togglefloating"
          "$mod, Space, exec, wofi --show drun"
          ", Print, exec, grim -g \"$(slurp)\" - | swappy -f -"
          "$mod SHIFT, Z, movetoworkspace, special"
          "$mod, Z, togglespecialworkspace"
          "$mod SHIFT, Space, fullscreen, 1"

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

          ", XF86MonBrightnessUp, exec, brightnessctl + 5%"
          ", XF86MonBrightnessDown, exec, brightnessctl - 5%"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioStop, exec, playerctl stop"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioNext, exec, playerctl next"
        ];
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
        binde = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ];
        bindl = [
          ", switch:off:Lid Switch, exec, hyprctl keyword monitopr \"eDP-1,preferred,auto,1.333333\""
          ", switch:on:Lid Switch, exec, hyprctl keyword monitor \"eDP-1,disable\""
        ];
        windowrulev2 = [
          "size 0 0,class:(ghidra-Ghidra),title:(Ghidra)"
          "center,class:(ghidra-Ghidra),title:(Ghidra)"
          "tile,class:(ghidra-Ghidra),title:^(Ghidra: )"
          "tile,class:(ghidra-Ghidra),title:(CodeBrowser)"
          "tile,title:^(Burp Suite Community Edition)"
        ];
      };
    };
  };
}
