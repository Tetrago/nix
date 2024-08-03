{ fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "okolors";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "Ivordir";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-xroiiDTm3B2sVC1sO7oe3deqh+j3URmiy/ctwqrvvkI=";
  };

  cargoSha256 = "sha256-Ru7VZM+vLGkYeLqWilQvpWUnbNZqkJHn1D/Vo/KUmRk=";
}
