{ theme, colors, pkgs }:

let
  colors2 = pkgs.writeText "colors2" ''
    gtk-color-scheme = "bg_color:#${colors.base00}
    color0:#${colors.base00}
    text_color:#${colors.base05}
    selected_bg_color:#${colors.base02}
    selected_fg_color:#${colors.base05}
    tooltip_bg_color:#${colors.base00}
    tooltip_fg_color:#${colors.base05}
    titlebar_bg_color:#${colors.base00}
    titlebar_fg_color:#${colors.base05}
    menu_bg_color:#${colors.base00}
    menu_fg_color:#${colors.base05}
    link_color:#${colors.base02}"
  '';
  colors3 = pkgs.writeText "colors3" ''
    @define-color bg_color #${colors.base00};
    @define-color fg_color #${colors.base05};
    @define-color base_color #${colors.base01};
    @define-color text_color #${colors.base05};
    @define-color text_color_disabled #${colors.base03};
    @define-color selected_bg_color #${colors.base02};
    @define-color selected_fg_color #${colors.base05};
    @define-color tooltip_bg_color #${colors.base00};
    @define-color tooltip_fg_color #${colors.base05};
  '';
in
pkgs.stdenvNoCC.mkDerivation {
  name = "base16-flat-${theme}-gtk";

  src = pkgs.fetchFromGitHub {
    owner = "jasperro";
    repo = "FlatColor";
    rev = "master";
    sha256 = "sha256-P8RnYTk9Z1rCBEEMLTVRrNr5tUM/Pc9dsdMtpHd1Y18=";
  };

  buildPhase = ''
    sed -i '/gtk-color-scheme/,/"/cinclude "../colors2"' gtk-2.0/gtkrc
    sed -i '/\/* Default color scheme/,/*\//c@import url ("../colors3");' gtk-3.0/gtk.css
    sed -i '/\/* Default color scheme/,/*\//c@import url ("../colors3");' gtk-3.20/gtk.css

    cp ${colors2} colors2
    cp ${colors3} colors3
  '';

  installPhase = ''
    mkdir -p $out/share/themes/base16-flat-${theme}-gtk
    cp -a ./. $out/share/themes/base16-flat-${theme}-gtk/
  '';
}
