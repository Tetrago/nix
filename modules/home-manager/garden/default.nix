{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins)
    attrNames
    length
    genList
    listToAttrs
    ;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  inherit (lib.attrsets) mapAttrsToList mapAttrs';
  inherit (lib.lists) zipLists;
in
{
  options.garden = {
    enable = mkEnableOption "garden desktop environment.";

    background = {
      light = mkOption {
        type = with types; nullOr path;
        default = null;
      };

      dark = mkOption {
        type = with types; nullOr path;
        default = null;
      };
    };

    keybindings = mkOption {
      type =
        with types;
        attrsOf (submodule {
          options = {
            binding = mkOption { type = str; };
            command = mkOption { type = str; };
          };
        });
      default = {
        firefox = {
          binding = "<Super>N";
          command = "firefox";
        };
        terminal = {
          binding = "<Super>Return";
          command = "ghostty";
        };
        explorer = {
          binding = "<Super>E";
          command = "nautilus";
        };
      };
    };

    extensions = mkOption {
      type = with types; listOf package;
      internal = true;
    };

    extraExtensions = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
  };

  config =
    let
      cfg = config.garden;

      applicationSettings = {
        "org/gnome/TextEditor" = {
          highlight-current-line = true;
          restore-session = false;
          keybindings = "vim";
        };

        "org/gnome/papers/default" = {
          show-sidebar = false;
          window-maximized = false;
        };
      };

      keybindingSettings = {
        "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = genList (
          x: "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString x}/"
        ) (length (attrNames cfg.keybindings));
      }
      // listToAttrs (
        map
          (x: {
            name = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString x.fst}";
            value = x.snd;
          })
          (
            zipLists (genList (x: x) (length (attrNames cfg.keybindings))) (
              mapAttrsToList (name: v: v // { inherit name; }) cfg.keybindings
            )
          )
      );

      extensionSettings = {
        just-perfection = {
          quick-settings-dark-mode = false;
          quick-settings-night-light = false;
          startup-status = 0;
          support-notifier-showed-version = 34;
          support-notifier-type = 0;
          world-clock = false;
        };

        caffeine = {
          enable-fullscreen = true;
          enable-mpris = true;
          show-notifications = false;
        };

        "blur-my-shell/panel".blur = false;
        "nightthemeswitcher/time".manual-schedule = false;
        workspace-indicator.embed-previews = false;

        paperwm = {
          minimap-scale = 0.0;
          open-window-position-option-left = false;
          selection-border-radius-bottom = 12;
          show-focus-mode-icon = false;
          show-workspace-indicator = false;
          winprops = [
            ''{"wm_class":"*", "preferredWidth":"50%"}''
          ];
        };

        "paperwm/keybindings" = {
          close-window = [ "<Super>w" ];
          live-alt-tab = [ "<Super>Tab" ];
          new-window = [ "" ];
          toggle-maximize-width = [ "<Super>p" ];
          toggle-scratch = [ "<Shift><Super>z" ];
          toggle-scratch-layer = [ "<Super>z" ];
        };

        search-light = {
          border-radius = 7.0;
          popup-at-cursor-monitor = true;
          scale-height = 0.3;
          scale-width = 0.5;
          shortcut-search = [ "<Super>space" ];
        };
      };
    in
    mkIf cfg.enable {
      garden.extensions =
        with pkgs.gnomeExtensions;
        [
          auto-accent-colour
          bluetooth-battery-meter
          blur-my-shell
          caffeine
          clipboard-indicator
          fuzzy-app-search
          just-perfection
          launch-new-instance
          night-theme-switcher
          paperwm
          search-light
        ]
        ++ cfg.extraExtensions;

      dconf = {
        enable = true;
        settings = {
          "org/gnome/desktop/background" = with cfg.background; {
            picture-url = mkIf (light != null) "file://${light}";
            picture-url-dark = mkIf (dark != null) "file://${dark}";
          };

          "org/gnome/desktop/datetime/automatic-timezone".enable = true;
          "org/gnome/desktop/input-sources".xkb-options = [ "ctrl:nocaps" ];
          "org/gnome/desktop/session".idle-delay = 600;
          "org/gnome/settings-daemon/plugins/media-keys".help = [ ];
          "org/gnome/shell/keybindings".focus-active-notification = [ ];
          "org/gnome/shell/weather".automatic-location = true;
          "org/gnome/system/location".enabled = true;
          "org/gtk/settings/file-chooser".clock-format = "12h";

          "org/gnome/desktop/wm/keybindings" = {
            switch-input-soruce = [ ];
            switch-input-soruce-backward = [ ];
          };

          "org/gnome/desktop/interface" = {
            clock-format = "12h";
            clock-show-date = false;
            enable-hot-corners = false;
          };

          "org/gnome/desktop/screen-time-limits" = {
            history-enabled = false;
            daily-limit-enabled = false;
          };

          "org/gnome/desktop/peripherals/mouse" = {
            speed = 0.5;
            accel-profile = "flat";
          };

          "org/gnome/settings-daemon/plugins/power" = {
            sleep-inactive-ac-type = "suspend";
            sleep-inactive-ac-timeout = 1800;
          };

          "org/gnome/shell".enabled-extensions = map (x: x.extensionUuid) cfg.extensions;

          "org/gnome/mutter" = {
            experimental-features = [
              "autoclose-xwayland"
              "scale-monitor-framebuffer"
              "variable-refresh-rate"
              "xwayland-native-scaling"
            ];
            workspaces-only-on-primary = false;
          };
        }
        // applicationSettings
        // keybindingSettings
        // mapAttrs' (n: value: {
          name = "org/gnome/shell/extensions/${n}";
          inherit value;
        }) extensionSettings;
      };
    };
}
