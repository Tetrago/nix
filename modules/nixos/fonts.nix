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
    enable = mkEnableOption "standard fonts.";
  };

  config =
    let
      cfg = config.tetrago.fonts;
    in
    mkIf cfg.enable {
      fonts.packages = with pkgs; [
        noto-fonts
        vistafonts
      ];
    };
}
