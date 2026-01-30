{
  blueprint-compiler,
  desktop-file-utils,
  fetchFromGitHub,
  gobject-introspection,
  gtk4,
  lib,
  libadwaita,
  libGL,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "Cine";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "diegopvlk";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-GQ8kN/3zX7iiCibGRnwe150EXi1duV8ANrmlREoLSbo=";
  };

  format = "other";

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  makeWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL ]}"
  ];

  propagatedBuildInputs = with python3.pkgs; [
    mpv
    pygobject3
  ];

  meta.mainProgram = "cine";
}
