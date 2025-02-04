{ inputs, ... }:

{
  imports = [ inputs.walker.homeManagerModules.default ];

  programs.walker = {
    enable = true;
    runAsService = false;
    config = {
      builtins.applications.actions = {
        enabled = false;
      };
    };
  };
}
