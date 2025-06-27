{ config, ... }:

{
  home.homeDirectory = "/home/${config.home.username}";
  programs.home-manager.enable = true;
}
