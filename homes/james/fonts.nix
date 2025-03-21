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
  options.james.fonts = {
    enable = mkEnableOption "font configuration.";
  };

  config =
    let
      cfg = config.james.fonts;
    in
    mkIf cfg.enable {
      home.packages = with pkgs; [
        adwaita-fonts
        monaspace
      ];

      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = [ "Adwaita Sans" ];
          monospace = [ "Monaspace Neon" ];
        };
      };
    };
}
