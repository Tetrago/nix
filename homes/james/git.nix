{ pkgs, ... }:

let
  gitignore = pkgs.writeText "gitignore" ''
    /.direnv/
    /.envrc
    /.vscode/
    /result
  '';
in
{
  programs.git = {
    enable = true;
    package = pkgs.git.override { withLibsecret = true; };

    difftastic.enable = true;
    lfs.enable = true;

    userName = "James";
    extraConfig = {
      core.excludesFile = "${gitignore}";
      credential.helper = "libsecret";
      init.defaultBranch = "develop";
      diff.tool = "meld";
    };
  };
}
