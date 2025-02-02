{ inputs, ... }:

{
  imports = [ inputs.walker.homeManagerModules.default ];

  nix.settings = {
    substituters = [ "https://walker.cachix.org" ];
    trusted-public-keys = [ "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM=" ];
  };

  programs.walker = {
    enable = true;
    runAsService = false;
  };
}
