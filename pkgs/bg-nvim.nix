{ fetchFromGitHub, vimUtils }:

vimUtils.buildVimPlugin rec {
  pname = "bg.nvim";
  version = "2024-06-16";

  src = fetchFromGitHub {
    owner = "typicode";
    repo = pname;
    rev = "61e1150dd5900eaf73700e4776088c2131585f99";
    sha256 = "sha256-qzBp5h9AkJWQ3X7TSwxX881klDXojefeH0Qn/prJ/78=";
  };

  meta.homepage = "https://github.com/typicode/bg.nvim/";
}
