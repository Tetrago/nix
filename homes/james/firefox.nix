{ ... }:

let
  userChrome = builtins.readFile(builtins.fetchurl {
    url = "https://raw.githubusercontent.com/crambaud/waterfall/main/userChrome.css";
    sha256 = "62008a97381cf0b8b57e5a0b39cf13305903f3b32e3b31fe209182bfe317affa";
  });
in
{
  programs.firefox = {
    enable = true;
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