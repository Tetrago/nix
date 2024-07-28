{
  fetchFromGitHub,
  vimUtils
}:

vimUtils.buildVimPlugin rec {
  pname = "nvim-recorder";
  version = "2024-07-09";

  src = fetchFromGitHub {
    owner = "chrisgrieser";
    repo = pname;
    rev = "2b307756704a0ba26e8a3adfe98d02eeaecaa52e";
    sha256 = "sha256-Uk46U3tW9qqc5ZKfEN3QhHLeuoPCboeAr6CrczG7jBA=";
  };

  meta.homepage = "https://github.com/chrisgrieser/nvim-recorder/";
}
