{
  fetchFromGitHub,
  rustPlatform,
  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "somo";
  version = "0.2.0";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  src = fetchFromGitHub {
    owner = "theopfr";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-9GwcApq9qLDCv0KA00wcynEfmEsqT20IKVrgS4f+hrE=";
  };

  cargoHash = "sha256-VupcyOuP3OKJpkzqQ9mhOUJdssdy9Jm8ipnzrzn5l3E=";
}
