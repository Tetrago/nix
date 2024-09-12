{
  buildFHSEnv,
  fetchurl,
  stdenvNoCC,
  unzip,
}:

let
  name = "binaryninja";

  env = buildFHSEnv {
    inherit name;

    targetPkgs =
      pkgs:
      (with pkgs; [
        dbus
        fontconfig
        freetype
        libGL
        libxkbcommon
        libxml2
        (python3.withPackages (pkgs: [ pkgs.torch ]))
        wayland
        zlib
      ])
      ++ (with pkgs.xorg; [
        libX11
        libxcb
        xcbutilimage
        xcbutilkeysyms
        xcbutilrenderutil
        xcbutilwm
      ]);

    runScript = "binaryninja";
  };
in
stdenvNoCC.mkDerivation {
  inherit name;

  src = fetchurl {
    url = "https://cdn.binary.ninja/installers/binaryninja_free_linux.zip";
    sha256 = "sha256-OCMOJKC0X0mGV3snfeumzHCXrnjobQb78dWQFv73uU4=";
  };

  nativeBuildInputs = [ unzip ];

  dontBuild = true;

  unpackPhase = ''
    mkdir -p $out/share
    unzip $src -d $out/share
  '';

  installPhase = ''
    mkdir -p $out/bin
    chmod +x $out/share/binaryninja/binaryninja
    ln -s $out/share/binaryninja/binaryninja $out/bin/binaryninja

    mkdir -p $out/share/applications
    cat > $out/share/applications/binaryninja.desktop <<EOF
    [Desktop Entry]
    Name=Binary Ninja
    Exec=${env}/bin/binaryninja %u
    Terminal=false
    Type=Application
    MimeType=application/x-binaryninja;x-scheme-handler/binaryninja
    Categories=Utility
    Comment=Binary Ninja: A Reverse Engineering Platform
    EOF
  '';
}
