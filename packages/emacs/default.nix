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

        alwaysEnsure = true;
        alwaysTangle = true;
        defaultInitFile = true;

        extraEmacsPackages =
          epkgs: with epkgs; [
            calt
            f
            goto-chg
            ht
            language-id
            llama
            lsp
            lv
            markdown-mode
            s
            spinner
            wgrep
            pkgs.clang-tools
            pkgs.nixfmt-rfc-style
            pkgs.ripgrep
            pkgs.rustfmt
          ];

        override = final: prev: {
          ultra-scroll = pkgs.callPackage ./ultra-scroll.nix { };
        };
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
