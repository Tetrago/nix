{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) listToAttrs;
  inherit (lib)
    mkIf
    mkOption
    types
    ;
  inherit (lib.attrsets) mapAttrs';

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

  auto-adwaita-colors = pkgs.gnomeExtensions.auto-adwaita-colors.overrideAttrs (
    final: prev: {
      version = "2026-04-30";

      src = pkgs.fetchFromGitHub {
        owner = "Dhanush-Projectile";
        repo = "auto-adwaita-colors";
        rev = "51238b785708d8f8acd04b0295264a98447cdaae";
        hash = "sha256-HJvwau9JgHml2QIGhZuCFQUnNU7g7Fz5cLiW9xQPmVk=";
      };

      postPatch =
        let
          utils = pkgs.writeText "utils.js" ''
            export async function fetchLatestVersion() {}
            export async function downloadZip(url, outputPath) {}

            export function getVariant() {
                return { found: true, state: 'user' };
            }

          '';
        in
        (prev.postPatch or "")
        + ''
          cp "${utils}" utils.js
        '';
    }
  );

  search-light = pkgs.gnomeExtensions.search-light.overrideAttrs (
    final: prev: rec {
      version = "g50";

      src = pkgs.fetchFromGitHub {
        owner = "icedman";
        repo = "search-light";
        rev = version;
        hash = "sha256-G2yV7kuZ5/TTovhsgfJneRQvrHl4Hwkkbehe8YJah/A=";
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
          status-icons
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
                  ''{"wm_class":"org.gnome.gitlab.cheywood.Buffer","scratch_layer":true}''
                  ''{"wm_class":"it.mijorus.collector","scratch_layer":true}''
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
        dataFile = listToAttrs (
          map (x: {
            name = "icons/${x}";
            value = {
              source = "${adwaita-colors}/${x}";
            };
          }) (import adwaita-colors)
        );
      };
    };
}
