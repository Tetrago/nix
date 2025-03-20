{
  inputs,
  pkgs,
}:

let
  calt = pkgs.callPackage ./calt.nix {
    font = "${pkgs.monaspace}/share/fonts/opentype/MonaspaceArgon-Regular.otf";
  };

  lsp = pkgs.callPackage ./lsp.nix { };

  tree-sitter-lib = pkgs.callPackage ./tree-sitter-lib.nix { };

  emacs =
    inputs.emacs-overlay.lib.${pkgs.stdenv.hostPlatform.system}.emacsWithPackagesFromUsePackage
      {
        config = ./init.org;

        package = pkgs.emacs-pgtk;
        alwaysEnsure = true;
        alwaysTangle = true;
        defaultInitFile = true;

        extraEmacsPackages =
          epkgs: with epkgs; [
            calt
            f
            fringe-helper
            goto-chg
            ht
            language-id
            llama
            lsp
            lv
            mathjax
            markdown-mode
            nerd-icons
            s
            shrink-path
            spinner
            tree-sitter-lib
            wgrep
            pkgs.clang-tools
            pkgs.nil
            pkgs.nixfmt-rfc-style
            pkgs.ripgrep
            pkgs.rustfmt
            pkgs.rust-analyzer
            pkgs.tree-sitter
            pkgs.tree-sitter-grammars.tree-sitter-rust
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
      --prefix XDG_DATA_DIRS : "${pkgs.monaspace}/share:${pkgs.nerd-fonts.symbols-only}/share"

    cp -r ${emacs}/share $out/share
  '';
}
