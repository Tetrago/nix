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

  useFetchCargoVendor = true;

  cargoHash = "sha256-SMNpDW7x7k0Tnpv9XlJDzW/sNSDtbS+Jkm26+iLivTM=";
}
