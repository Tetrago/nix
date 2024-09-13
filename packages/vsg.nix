{ python312Packages }:

with python312Packages;
buildPythonPackage rec {
  pname = "vsg";
  version = "3.25.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3jVkyeGMPPUktYXwI7DbByiyPMefuvXx++5y+Xr+69I=";
  };

  nativeBuildInputs = [
    setuptools-scm
    setuptools-git-versioning
  ];

  propagatedBuildInputs = [ pyyaml ];
}
