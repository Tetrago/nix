{ config, lib, pkgs, ... }:

{
  options = {
    fonts.enable = lib.mkEnableOption "enable standard fonts";
  };

  config = lib.mkIf config.fonts.enable {
    fonts.packages = with pkgs; [
      corefonts
      noto-fonts
      vistafonts
      (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };
}
