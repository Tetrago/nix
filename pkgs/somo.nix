{
  fetchFromGitHub,
  rustPlatform,
  openssl,
  pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "somo";
  version = "v0.2.0";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  src = fetchFromGitHub {
    owner = "theopfr";
    repo = pname;
    rev = version;
    hash = "sha256-9GwcApq9qLDCv0KA00wcynEfmEsqT20IKVrgS4f+hrE=";
  };

  cargoSha256 = "sha256-LlmyTbNIxQ6/YHbIGW5PS8qUh3QdaUkEmEHgqy6YBD4=";
}
