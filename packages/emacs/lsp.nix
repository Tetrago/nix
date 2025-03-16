{
  clang-tools,
  emacsPackages,
  writeText,
}:

emacsPackages.trivialBuild {
  name = "emacs-lsp";

  src = writeText "lsp.el" ''
    (defun load-lsp ()
      (setq lsp-clangd-binary-path "${clang-tools}/bin/clangd"))

    (provide 'lsp)
  '';
}
