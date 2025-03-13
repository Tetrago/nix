{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;

  theme = pkgs.whitesur-firefox-theme.override {
    themeName = "Monterey";
    variant = "adaptive";
  };
in
{
  options.james.firefox = {
    enable = mkEnableOption "Firefox configuration.";
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

        profiles.default = {
          inherit (theme) settings;
        };
      };

      home.file.".mozilla/firefox/default/chrome".source = theme.package;
    };
}
