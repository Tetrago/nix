{
  fetchFromGitHub,
  gtk-engine-murrine,
  inkscape,
  optipng,
  sassc,
  stdenv,
  highlight-color ? "123456",
  highlight-text-color ? "987654"
}:

stdenv.mkDerivation rec {
  pname = "flat-remix-gtk-variant";
  version = "20220627";

  src = fetchFromGitHub {
    owner = "daniruiz";
    repo = "flat-remix-gtk";
    rev = version;
    sha256 = "sha256-z/ILu8UPbyEN/ejsxZ3CII3y3dI04ZNa1i6nyjKFis8=";
  };

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  nativeBuildInputs = [
    inkscape
    optipng
    sassc
  ];

  buildPhase = ''
    ./generate-color-theme.sh variant '#${highlight-color}' '#${highlight-text-color}'
  '';

  installPhase = ''
    mkdir -p $out/share/themes/
    cp -a ./themes/Flat-Remix-GTK-variant-Dark-Solid $out/share/themes/flat-remix-gtk-variant-dark
    cp -a ./themes/Flat-Remix-GTK-variant-Light-Solid $out/share/themes/flat-remix-gtk-variant-light
  '';
}