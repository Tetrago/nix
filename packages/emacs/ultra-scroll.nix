{
  emacsPackages,
  fetchFromGitHub,
}:

emacsPackages.trivialBuild rec {
  pname = "ultra-scroll";
  version = "2025-03-12";

  src = fetchFromGitHub {
    owner = "jdtsmith";
    repo = pname;
    rev = "b72c507f6702db18d971a6b6bdc692e260f21159";
    hash = "sha256-AehGNc8ll/Q0HVp1OCj1bVBuXNh0Y43kp5EteSpwvmQ=";
  };
}
