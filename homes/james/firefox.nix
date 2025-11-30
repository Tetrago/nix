{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
in
{
  options.james.firefox = {
    enable = mkEnableOption "Firefox configuration.";
    theme.enable = mkEnableOption "GNOME theme.";
  };

  config =
    let
      cfg = config.james.firefox;
    in
    mkIf cfg.enable {
      programs.firefox = {
        enable = true;
        package = pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) { };

        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableFirefoxScreenshots = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          DontCheckDefaultBrowser = true;
          DisplayBookmarksToolbar = "never";

          ExtensionSettings =
            let
              plug = name: {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
                installation_mode = "force_installed";
              };
            in
            {
              "addon@fastforward.team" = plug "fastforwardteam";
              "sponsorBlocker@ajay.app" = plug "sponsorblock";
              "uBlock0@raymondhill.net" = plug "ublock-origin";
              "{b9db16a4-6edc-47ec-a1f4-b86292ed211d}" = plug "video-downloadhelper";
              "addon@darkreader.org" = plug "darkreader";
              "Google_AI_Overviews_Blocker@zachbarnes.dev" = plug "hide-google-ai-overviews";
              "izer@camelcamelcamel.com" = plug "the-camelizer-price-history-ch";
            };

          Preferences = {
            "extensions.pocket.enabled" = false;
            "extensions.screenshots.disabled" = true;
            "browser.topsites.contile.enabled" = false;
            "browser.formfill.enable" = false;
            "browser.search.suggest.enabled" = false;
            "browser.search.suggest.enabled.private" = false;
            "browser.urlbar.suggest.searches" = false;
            "browser.urlbar.showSearchSuggestionsFirst" = false;
            "media.getusermedia.audio.aprocessing.aec.enabled" = false;
            "media.getusermedia.audio.aprocessing.agc.enabled" = false;
            "media.getusermedia.audio.aprocessing.hpf.enabled" = false;
            "media.getusermedia.audio.aprocessing.noise.enabled" = false;
          };
        };

        profiles.default.settings = mkIf cfg.theme.enable {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "svg.context-properties.content.enabled" = true;
          "browser.uidensity" = 0;
          "browser.theme.dark-private-windows" = false;
          "widget.gtk.rounded-bottom-corners.enabled" = true;
        };
      };

      home.file.".mozilla/firefox/default/chrome" = mkIf cfg.theme.enable {
        source = pkgs.fetchFromGitHub {
          owner = "rafaelmardojai";
          repo = "firefox-gnome-theme";
          rev = "v137";
          hash = "sha256-oiHLDHXq7ymsMVYSg92dD1OLnKLQoU/Gf2F1GoONLCE=";
        };
      };
    };
}
