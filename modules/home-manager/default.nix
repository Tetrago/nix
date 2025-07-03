{ config, ... }:

{
  imports = [ ./nautilus.nix ];

  home.homeDirectory = "/home/${config.home.username}";
  programs.home-manager.enable = true;
}
