{ pkgs, ... }:

let
  userChrome = builtins.readFile (
    builtins.fetchurl {
      url = "https://raw.githubusercontent.com/crambaud/waterfall/main/userChrome.css";
      sha256 = "62008a97381cf0b8b57e5a0b39cf13305903f3b32e3b31fe209182bfe317affa";
    }
  );
in
{
  programs.firefox = {
    enable = true;
    package = (
      pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) {
        extraPolicies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableFirefoxScreenshots = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          DontCheckDefaultBrowser = true;
          DisplayBookmarksToolbar = "never";

          ExtensionSessings =
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
      }
    );

    profiles.default = {
      userChrome = userChrome;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "layers.acceleration.force-enabled" = true;
        "gfx.webrender.all" = true;
        "svg.context-properties.content.enabled" = true;
      };
    };
  };
}
