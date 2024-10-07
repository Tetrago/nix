{
  python3Packages,
  fetchFromGitHub,
  capstone,
  makeWrapper,
}:

python3Packages.buildPythonPackage {
  name = "ropium";

  src = fetchFromGitHub {
    owner = "mechgt";
    repo = "ropium";
    rev = "212ed51438151c609b86d692e6e863c2c44f3781";
    sha256 = "sha256-8GyqylQL86E9JvGigUmLcHF5TzY33BB3RdY+eoBaPW8=";
  };

  format = "other";

  buildInputs = [
    capstone
    makeWrapper
  ];

  dependencies = with python3Packages; [
    prompt-toolkit
    ropgadget
  ];

  preInstall = ''
    makeFlagsArray+=("DESTDIR=$out" "PREFIX=")
    sed -i "s|PYTHONDIR=.*|PYTHONDIR=$out/${python3Packages.python.sitePackages}|" Makefile
  '';
}
