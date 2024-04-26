{ pkgs, ... }:

let
  teroshdl = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "teroshdl";
      publisher = "teros-technology";
      version = "6.0.0";
      sha256 = "sha256-XSPaZL0mSGJHUwl+PUQMmrdGjO/k6yUiwaxTAP0vT+c=";
    };
  };
in
{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    mutableExtensionsDir = false;
    userSettings = {
      "editor.lineNumbers" = "relative";
      "window.titleBarStyle" = "custom";
      "workbench.startupEditor" = "none";
      "editor.minimap.enabled" = false;
      "editor.fontLigatures" = true;
      "editor.fontFamily" = "'FiraCode Nerd Font', 'Droid Sans Mono', 'monospace', monospace";
      "workbench.layoutControl.enabled" = false;
      "terminal.integrated.profiles.linux"."bash" = {
        path = "${pkgs.bashInteractive}/bin/bash";
        args = [ "-l" ];
      };
      "terminal.integrated.defaultProfile.linux" = "bash";
      "explorer.excludeGitIgnore" = true;
      "[nix]" = {
        "editor.tabSize" = 2;
      };
      "svelte.enable-ts-plugin" = true;
      "files.exclude" = {
        "**/.direnv" = true;
        "**/.envrc" = true;
      };
      "update.showReleaseNotes" = false;
      "workbench.editor.customLabels.patterns" = {
        "**/default.nix" = "\${dirname} (nix)";
        "**/+page.svelte" = "\${dirname} (page)";
        "**/+page.client.js" = "\${dirname} (client)";
        "**/+page.server.js" = "\${dirname} (server)";
      };
    };
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      vscodevim.vim
      mkhl.direnv
      tomoki1207.pdf
      ms-vscode.hexeditor

      svelte.svelte-vscode

      golang.go

      ms-vscode.cpptools
      ms-vscode.cmake-tools
      ms-azuretools.vscode-docker

      serayuzgur.crates
      rust-lang.rust-analyzer
      tamasfe.even-better-toml

      teroshdl

      nvarner.typst-lsp

      justusadam.language-haskell
      haskell.haskell
    ];
  };
}
