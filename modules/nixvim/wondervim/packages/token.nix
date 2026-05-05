{
  fetchFromGitHub,
  vimUtils,
}:

vimUtils.buildVimPlugin rec {
  pname = "token";
  version = "1.19.1";

  src = fetchFromGitHub {
    owner = "ThorstenRhau";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-1KIZmxP++Fc3Mwe/pvXwhO+US4GlC7oUuzpISRZCyVQ=";
  };

  meta.homepage = "https://github.com/ThorstenRhau/token/";
  meta.hydraPlatforms = [ ];
}
