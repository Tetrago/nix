{
  bintools-unwrapped,
  fetchFromGitHub,
  file,
  gdb,
  lib,
  makeWrapper,
  ps,
  python3,
  stdenvNoCC
}:

let
  pythonPath = with python3.pkgs; makePythonPath [
    keystone-engine
    unicorn
    capstone
    ropper
  ];
in
stdenvNoCC.mkDerivation rec {
  pname = "gef";
  version = "2023.08";

  src = fetchFromGitHub {
    owner = "hugsy";
    repo = "gef";
    rev = version;
    sha256 = "sha256-MqpII3jhSc6aP/WQDktom2wxAvCkxCwfs1AFWij5J7A=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/gef
    cp gef.py $out/share/gef/

    makeWrapper ${gdb}/bin/gdb $out/bin/gdb \
      --add-flags "-q -x $out/share/gef/gef.py" \
      --set NIX_PYTHONPATH ${pythonPath} \
      --prefix PATH : ${lib.makeBinPath [
        python3
        bintools-unwrapped
        file
        ps
      ]}
  '';
}