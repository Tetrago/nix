{ fetchFromGitHub, rustPlatform, spotify }:

let
  spotify-adblock = rustPlatform.buildRustPackage rec {
    pname = "spotify-adblock";
    version = "1.0.3";

    src = fetchFromGitHub {
      owner = "abba23";
      repo = pname;
      rev = "v${version}";
      sha256 = "UzpHAHpQx2MlmBNKm2turjeVmgp5zXKWm3nZbEo0mYE=";
    };

    cargoSha256 = "wPV+ZY34OMbBrjmhvwjljbwmcUiPdWNHFU3ac7aVbIQ=";

    patchPhase = ''
      substituteInPlace src/lib.rs \
        --replace 'config.toml' $out/etc/spotify-adblock/config.toml
    '';

    buildPhase = ''
      make
    '';

    installPhase = ''
      mkdir -p $out/etc/spotify-adblock
      install -D --mode=644 config.toml $out/etc/spotify-adblock/config.toml
      mkdir -p $out/lib
      install -D --mode=644 --strip target/release/libspotifyadblock.so $out/lib/libspotifyadblock.so
    '';
  };
in spotify.overrideAttrs (final: prev: {
  postInstall = (prev.postInstall or "") + ''
    wrapProgram $out/bin/spotify \
      --set LD_PRELOAD "${spotify-adblock}/lib/libspotifyadblock.so"
  '';
})
