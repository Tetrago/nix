{ fetchFromGitHub, vimUtils }:

vimUtils.buildVimPlugin rec {
  pname = "neotree-file-nesting-config";
  version = "2025-06-03";

  src = fetchFromGitHub {
    owner = "saifulapm";
    repo = pname;
    rev = "089adb6d3e478771f4485be96128796fb01a20c4";
    hash = "sha256-VCwujwpiRR8+MLcLgTWsQe+y0+BYL9HRZD+OzafNGGA=";
  };

  meta.homepage = "https://github.com/saifulapm/neotree-file-nesting-config";
}
