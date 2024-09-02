{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.tetrago.fonts = {
    enable = mkEnableOption "enable standard fonts";
  };

  config = mkIf config.tetrago.fonts.enable {
    fonts.packages = with pkgs; [
      noto-fonts
      vistafonts
      (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };
}
