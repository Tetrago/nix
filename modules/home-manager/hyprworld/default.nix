{ config, lib, host, pkgs, ... }:

{
  options.hyprworld = {
    background = {
      enable = lib.mkEnableOption "enable desktop background";
      wallpaper = lib.mkOption {
        type = lib.types.str;
        description = "path to wallpaper";
        example = "~/wallpaper.jpg";
      };
    };
  };

  config = {
    home = {
      packages = with pkgs; [
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
        networkmanagerapplet
        vscode
      ];

      file = {
        ".config/hypr/hyprpaper.conf".text = let path = config.hyprworld.background.wallpaper; in ''
          preload = ${path}
          wallpaper = ,${path}
          ipc = off
          splash = off
        '';
        ".config/hypr/hypridle.conf".text = import ./hypridle.nix { inherit pkgs; };
        ".config/hypr/hyprlock.conf".text = import ./hyprlock.nix { colors = config.colorScheme.palette; };
        ".config/swaync/style.css".text = import ./swaync.nix { colors = config.colorScheme.palette; };
        ".config/nwg-bar/bar.json".text = ''
          [
            {
              "label": "Lock",
              "exec": "loginctl lock-session",
              "icon": "${pkgs.nwg-bar}/share/nwg-bar/images/system-lock-screen.svg"
            },
            {
              "label": "Logout",
              "exec": "hyprctl dispatch exit",
              "icon": "${pkgs.nwg-bar}/share/nwg-bar/images/system-log-out.svg"
            },
            {
              "label": "Reboot",
              "exec": "systemctl reboot",
              "icon": "${pkgs.nwg-bar}/share/nwg-bar/images/system-reboot.svg"
            },
            {
              "label": "Shutdown",
              "exec": "systemctl -i poweroff",
              "icon": "${pkgs.nwg-bar}/share/nwg-bar/images/system-shutdown.svg"
            }
          ]
        '';
        ".config/nwg-bar/style.css".text = let c = config.colorScheme.palette; in ''
          window { background-color: #${c.base00}; }
          #outer-box { margin: 0px; }

          #inner-box {
            background-color: #${c.base00};
            border-radius: 10px;
            border-style: none;
            border-width: 1px;
            border-color: #${c.base04};
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
            margin: 5px;
            color: #${c.base04};
          }

          button:hover {
            background-color: #${c.base01};
          }
        '';
      };
    };

    programs = {
      alacritty.enable = true;
      wofi = import ./wofi.nix { colors = config.colorScheme.palette; };
      waybar = import ./waybar.nix { colors = config.colorScheme.palette; };
    };

    services = {
      blueman-applet.enable = host.bluetooth;
      kanshi = import ./kanshi.nix {
        inherit host;
        inherit lib;
      };
      mpd = {
        enable = true;
        musicDirectory = "/home/james/Music";
      };
      mpd-mpris.enable = true;
      network-manager-applet.enable = true;
      udiskie = {
        enable = true;
        automount = true;
        notify = true;
      };
    };

    wayland.windowManager.hyprland = import ./hyprland.nix { inherit pkgs; };
  };
}
