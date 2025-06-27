{
  fetchFromGitHub,
  vimUtils,
}:

vimUtils.buildVimPlugin rec {
  pname = "mellifluous.nvim";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "ramojus";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-H4JsnwCr7mRN22yVfKFvO3Fh0QMjDCzzOhBu1Pn1knU=";
  };
}
