{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  vulkan-loader,
}:

buildGoModule rec {
  pname = "gowall";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Achno";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-QKukWA8TB0FoNHu0Wyco55x4oBY+E33qdoT/SaXW6DE=";
  };

  vendorHash = "sha256-H2Io1K2LEFmEPJYVcEaVAK2ieBrkV6u+uX82XOvNXj4=";

  buildInputs = [
    vulkan-loader
  ];

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd gowall \
      --bash <($out/bin/gowall completion bash) \
      --fish <($out/bin/gowall completion fish) \
      --zsh <($out/bin/gowall completion zsh)
  '';
}
