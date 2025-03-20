{
  emacsPackages,
  lib,
  stdenvNoCC,
  tree-sitter-grammars,
  writeText,
  languages ? [
    "css"
    "cpp"
    "comment"
    "cmake"
    "c-sharp"
    "c"
    "make"
    "markdown"
    "markdown-inline"
    "nix"
    "lua"
    "jsdoc"
    "json"
    "java"
    "javascript"
    "go"
    "glsl"
    "python"
    "regex"
    "rust"
    "scss"
    "toml"
    "tsx"
    "typst"
    "verilog"
    "yaml"
    "zig"
  ],
}:

let
  package = stdenvNoCC.mkDerivation {
    name = "tree-sitter-lib";

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out

      ${lib.strings.concatLines (
        map (
          x: "ln -s ${tree-sitter-grammars."tree-sitter-${x}"}/parser $out/libtree-sitter-${x}.so"
        ) languages
      )}
    '';
  };
in
emacsPackages.trivialBuild {
  name = "emacs-tree-sitter-lib";

  src = writeText "tree-sitter-lib.el" ''
    (defun set-tree-sitter-lib-path ()
      (setq treesit-extra-load-path '("${package}")))

    (provide 'tree-sitter-lib)
  '';
}
