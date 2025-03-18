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
          let
            maple-minibuffer = pkgs.emacsPackages.trivialBuild rec {
              pname = "maple-minibuffer";
              version = "2021-10-16";

              src = pkgs.fetchFromGitHub {
                owner = "honmaple";
                repo = "emacs-${pname}";
                rev = "21a62e10c2c721d772e1fcf5de6aa4166baaea56";
                hash = "sha256-8LhpQqJwmlMyu74h6Zd0G+Tjyqm3sJCBet0MBzJtamg=";
              };
            };
          in
          epkgs: with epkgs; [
            calt
            f
            goto-chg
            ht
            language-id
            llama
            lsp
            lv
            maple-minibuffer
            markdown-mode
            s
            spinner
            wgrep
            pkgs.clang-tools
            pkgs.nixfmt-rfc-style
            pkgs.ripgrep
            pkgs.rustfmt
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
