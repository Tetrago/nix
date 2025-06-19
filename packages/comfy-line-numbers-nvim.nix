{ fetchFromGitHub, vimUtils }:

vimUtils.buildVimPlugin rec {
  pname = "comfy-line-numbers.nvim";
  version = "2025-05-27";

  src = fetchFromGitHub {
    owner = "mluders";
    repo = pname;
    rev = "eb1c966e22fbabe3a3214c78bda9793ccf9d2a5d";
    hash = "sha256-KaHhmm7RhJEtWedKE7ab+Aioe3jJLP0TUlnokszU5DY=";
  };

  meta.homepage = "https://github.com/mluders/comfy-line-numbers.nvim";
}
