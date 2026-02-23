{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption types;
  inherit (lib.attrsets) mapAttrs' mergeAttrsList;

  adwaita-colors = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "Adwaita-colors";
    version = "2.5";

    src = pkgs.fetchFromGitHub {
      owner = "dpejoh";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-AkEKbEWWOqKpm1Pyp8zbGoBuvwz2192kyAmGN8HPbSA=";
    };

    dontBuild = true;

    installPhase = ''
      mkdir -p $out

      # Handles buggy symlinks in the repository
      ${pkgs.rsync}/bin/rsync -a --no-links --no-perms ./Adwaita-* $out/

      echo "[" > $out/default.nix

      for c in Adwaita-*; do
        echo "\"$c\"" >> $out/default.nix
      done

      echo "]" >> $out/default.nix
    '';
  };

  dataDirs = mergeAttrsList (
    map (x: {
      "icons/${x}".source = "${adwaita-colors}/${x}";
    }) (import adwaita-colors)
  );

  auto-adwaita-colors = pkgs.gnomeExtensions.auto-adwaita-colors.overrideAttrs (
    final: prev: {
      version = "2025-11-19";

      src = pkgs.fetchFromGitHub {
        owner = "celiopy";
        repo = "auto-adwaita-colors";
        rev = "8b5bd3cef22198611e649dca55726424148828ea";
        hash = "sha256-yTFJnYQhywRQ8BrO1i5ImW1SEslPs+HJgBVufMe991A=";
      };
    }
  );
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

    extraExtensionConfig = mkOption {
      type = types.attrs;
      default = { };
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
          auto-adwaita-colors
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
          (
            cfg.extraExtensionConfig
            // {
              "blur-my-shell/panel".blur = false;
              "nightthemeswitcher/time".manual-schedule = false;
              auto-adwaita-colors.notify-about-releases = false;
              workspace-indicator.embed-previews = false;

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

              paperwm = {
                minimap-scale = 0.0;
                open-window-position-option-left = false;
                selection-border-radius-bottom = 12;
                show-focus-mode-icon = false;
                show-workspace-indicator = false;
                winprops = [
                  ''{"wm_class":"*","preferredWidth":"50%"}''
                  ''{"wm_class":"com.github.neithern.g4music","scratch_layer":true}''
                  ''{"wm_class":"com.gnome.gitlab.cheywood.Buffer","scratch_layer":true}''
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
            }
          );

      xdg = {
        enable = true;
        dataFile = dataDirs;
      };
    };
}
