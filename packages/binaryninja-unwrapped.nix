{
  fetchurl,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation {
  pname = "binaryninja";
  version = "4.1.5902";

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
    Exec=binaryninja %u
    Terminal=false
    Type=Application
    MimeType=application/x-binaryninja;x-scheme-handler/binaryninja
    Categories=Utility
    Comment=Binary Ninja: A Reverse Engineering Platform
    EOF
  '';
}