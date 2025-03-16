{
  inputs,
  pkgs,
}:

let
  calt = pkgs.callPackage ./calt.nix {
    font = "${pkgs.monaspace}/share/fonts/opentype/MonaspaceArgon-Regular.otf";
  };

  lsp = pkgs.callPackage ./lsp.nix { };

  emacs =
    inputs.emacs-overlay.lib.${pkgs.stdenv.hostPlatform.system}.emacsWithPackagesFromUsePackage
      {
        config = ./init.org;
        defaultInitFile = true;
        alwaysEnsure = true;

        extraEmacsPackages =
          epkgs: with epkgs; [
            calt
            f
            goto-chg
            ht
            lsp
            lv
            markdown-mode
            s
            spinner
          ];
      };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "emacs";
  dontUnpack = true;

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${emacs}/bin/emacs $out/bin/emacs \
      --prefix XDG_DATA_DIRS : "${pkgs.monaspace}/share"

    cp -r ${emacs}/share $out/share
  '';
}
