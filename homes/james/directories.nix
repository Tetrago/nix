{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.strings) concatLines;
in
{
  options.james.directories = {
    enable = mkEnableOption "directory management.";
  };

  config =
    let
      cfg = config.james.directories;
    in
    mkIf cfg.enable {
      xdg = {
        enable = true;
        userDirs = {
          enable = true;
          createDirectories = false;
          desktop = null;
          publicShare = null;
          templates = pkgs.runCommand "templates" { } ''
            mkdir -p $out
            ${concatLines (
              mapAttrsToList (n: v: ''touch "$out/New ${n} File.${v}"'') {
                Text = "txt";
                Markdown = "md";
              }
            )}
          '';
        };
      };
    };
}
