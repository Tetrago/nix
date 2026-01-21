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
      programs = {
        difftastic = {
          enable = true;
          git.enable = true;
        };

        git = {
          enable = true;
          package = mkIf cfg.enableLibsecretIntegration (pkgs.git.override { withLibsecret = true; });
          lfs.enable = true;

          settings = {
            core.excludesFile = "${gitignore}";
            credential.helper = mkIf cfg.enableLibsecretIntegration "libsecret";
            diff.tool = "meld";
            init.defaultBranch = "develop";
            user.name = "James";
          };
        };
      };
    };
}
