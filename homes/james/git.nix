{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;

  gitignore = pkgs.writeText "gitignore" ''
    /.direnv/
    /.envrc
    /.vscode/
    /result
  '';
in
{
  options.james.git = {
    enable = mkEnableOption "git configuration.";
    enableLibsecretIntegration = mkEnableOption "integration with libsecret.";
  };

  config =
    let
      cfg = config.james.git;
    in
    mkIf cfg.enable {
      programs.git = {
        enable = true;
        package = mkIf cfg.enableLibsecretIntegration (pkgs.git.override { withLibsecret = true; });

        difftastic.enable = true;
        lfs.enable = true;

        userName = "James";
        extraConfig = {
          core.excludesFile = "${gitignore}";
          credential.helper = mkIf cfg.enableLibsecretIntegration "libsecret";
          init.defaultBranch = "develop";
          diff.tool = "meld";
        };
      };
    };
}
