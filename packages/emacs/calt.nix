{
  stdenvNoCC,
  emacsPackages,
  python3,
  writeText,
  font,
}:

let
  export = stdenvNoCC.mkDerivation {
    name = "calt-export";
    dontUnpack = true;

    nativeBuildInputs = [
      (python3.withPackages (
        ps: with ps; [
          fontforge
          fonttools
        ]
      ))
    ];

    buildPhase = ''
      python3 ${./export_calt.py} ${font} | grep -v -P '[^\x00-\x7F]' | sed 's/[\"\\#,]/\\&/g' | sed 's/.*/"&"/' > ./out.txt
    '';

    installPhase = ''
      cp ./out.txt $out
    '';
  };
in
emacsPackages.trivialBuild {
  name = "emacs-calt";

  src = writeText "calt.el" ''
    (defun calt-ligatures ()
      '(${builtins.readFile export}))

    (provide 'calt)
  '';
}
