{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption types;
  inherit (lib.attrsets) mapAttrs';
in
{
  options.garden = {
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
    in
    mkIf cfg.enable {
      garden.extensions =
        with pkgs.gnomeExtensions;
        [
          auto-accent-colour
          auto-power-profile
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

      dconf.settings =
        mapAttrs'
          (n: value: {
            name = "org/gnome/shell/extensions/${n}";
            inherit value;
          })
          ({

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
          });
    };
}
