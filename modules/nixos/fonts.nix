{ config, lib, pkgs, ... }:

{
  options = {
    fonts.enable = lib.mkEnableOption "enable standard fonts";
  };

  config = lib.mkIf config.fonts.enable {
    fonts.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      fira-code
      fira-code-symbols
    ];
  };
}
