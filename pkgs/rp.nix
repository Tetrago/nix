{
  cmake,
  fetchFromGitHub,
  ninja,
  stdenv,
  makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "rp++";
  version = "v2.1.3";

  nativeBuildInputs = [
    cmake
    ninja
    makeWrapper
  ];

  src = fetchFromGitHub {
    owner = "0vercl0k";
    repo = "rp";
    rev = version;
    sha256 = "sha256-f/4NREarLvQ1cH50M7AT5B5xxS3yrYaCM6Sf+oVGUQk=";
  };

  dontUseCmakeConfigure = true;

  buildPhase = ''
    chmod +x ./src/build/build-release.sh
    cd ./src/build
    ./build-release.sh
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./rp-lin $out/bin/rp++

    wrapProgram $out/bin/rp++ \
      --add-flags "--colors"
  '';
}
