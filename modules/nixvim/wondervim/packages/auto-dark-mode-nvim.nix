{
  fetchFromGitHub,
  vimUtils,
}:

vimUtils.buildVimPlugin rec {
  pname = "auto-dark-mode.nvim";
  version = "2025-06-23";

  src = fetchFromGitHub {
    owner = "f-person";
    repo = pname;
    rev = "97a86c9402c784a254e5465ca2c51481eea310e3";
    hash = "sha256-zedwqG5PeJiSAZCl3GeyHwKDH/QjTz2OqDsFRTMTH/A=";
  };
}
