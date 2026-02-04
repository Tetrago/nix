{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  inherit (lib.attrsets) mapAttrs';
in
{
  imports = [
    ./applications.nix
    ./keybindings.nix
    ./extensions.nix
  ];

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
  };

  config =
    let
      cfg = config.garden;

      applicationSettings = {
        TextEditor = {
          highlight-current-line = true;
          restore-session = false;
          keybindings = "vim";
        };

        "papers/default" = {
          show-sidebar = false;
          window-maximized = false;
        };
      };

      deSettings = {
        "desktop/datetime/automatic-timezone".enable = true;
        "desktop/input-sources".xkb-options = [ "ctrl:nocaps" ];
        "desktop/session".idle-delay = 600;
        "org/gtk/settings/file-chooser".clock-format = "12h";
        "settings-daemon/plugins/media-keys".help = [ ];
        "shell/keybindings".focus-active-notification = [ ];
        "shell/weather".automatic-location = true;
        "system/location".enabled = true;

        "desktop/background" = with cfg.background; {
          picture-uri = mkIf (light != null) "file://${light}";
          picture-uri-dark = mkIf (dark != null) "file://${dark}";
        };

        "desktop/wm/keybindings" = {
          switch-input-source = [ ];
          switch-input-source-backward = [ ];
        };

        "desktop/interface" = {
          clock-format = "12h";
          clock-show-date = false;
          enable-hot-corners = false;
          cursor-theme = "BreezeX-RosePine-Linux";
        };

        "desktop/screen-time-limits" = {
          history-enabled = false;
          daily-limit-enabled = false;
        };

        "desktop/peripherals/mouse" = {
          speed = 0.5;
          accel-profile = "flat";
        };

        "settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "suspend";
          sleep-inactive-ac-timeout = 1800;
        };

        shell = {
          enabled-extensions = map (x: x.extensionUuid) cfg.extensions;
          favorite-apps = [ ];
        };

        mutter = {
          experimental-features = [
            "autoclose-xwayland"
            "scale-monitor-framebuffer"
            "variable-refresh-rate"
            "xwayland-native-scaling"
          ];
          workspaces-only-on-primary = false;
        };
      };
    in
    mkIf cfg.enable {
      home.packages = with pkgs; [ rose-pine-cursor ];

      dconf = {
        enable = true;
        settings = mapAttrs' (n: value: {
          name = "org/gnome/${n}";
          inherit value;
        }) (applicationSettings // deSettings);
      };
    };
}
