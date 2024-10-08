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
    delta.enable = true;
    lfs.enable = true;
    userName = "James";
    extraConfig = {
      core.excludesFile = "${gitignore}";
      init.defaultBranch = "develop";
    };
  };
}
