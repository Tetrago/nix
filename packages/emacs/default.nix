{
  inputs,
  pkgs,
}:

let
  inherit (pkgs) callPackage;

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
            f
            fringe-helper
            goto-chg
            ht
            language-id
            llama
            lv
            mathjax
            markdown-mode
            nerd-icons
            s
            shrink-path
            spinner
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
          calt = callPackage ./calt.nix {
            font = "${pkgs.monaspace}/share/fonts/opentype/MonaspaceArgon-Regular.otf";
          };
          lsp = callPackage ./lsp.nix { };
          tree-sitter-lib = callPackage ./tree-sitter-lib.nix { };
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
