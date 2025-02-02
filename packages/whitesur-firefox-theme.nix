{
  stdenvNoCC,
  fetchFromGitHub,
  themeName ? "WhiteSur",
  variant ? "",
}:

{
  settings = {
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "browser.tabs.drawInTitlebar" = true;
    "browser.uidensity" = 0;
    "layers.acceleration.force-enabled" = true;
    "mozilla.widget.use-argb-visuals" = true;
    "widget.gtk.rounded-bottom-corners.enabled" = true;
    "svg.context-properties.content.enabled" = true;
  };

  package = stdenvNoCC.mkDerivation rec {
    pname = "WhiteSur-firefox-theme";
    version = "2024-11-29";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = pname;
      rev = version;
      sha256 = "sha256-lsyy2xDNAh5BWlOvin1KAVhmHrgFYc1rMSg7DteJ0T0=";
    };

    buildPhase = ''
      mkdir ./${themeName}
      cp --no-preserve=mode -r $src/src/${themeName} .
      cp --no-preserve=mode -r $src/src/common/{icons,titlebuttons,pages} ./${themeName}
      cp --no-preserve=mode $src/src/common/*.css ./${themeName}
      cp --no-preserve=mode $src/src/common/parts/*.css ./${themeName}/parts
    '';

    installPhase =
      let
        fullName = ''${themeName}${if (variant != "") then "-${variant}" else ""}'';
      in
      ''
        runHook preInstall

        mkdir -p $out
        cp -r ./${themeName} $out
        cp $src/src/userChrome-${fullName}.css $out/userChrome.css
        cp $src/src/userContent-${fullName}.css $out/userContent.css

        runHook postInstall
      '';
  };
}
