{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.strings) concatStringsSep;
in
{
  options.greetd = {
    enable = mkEnableOption "enable greetd";
  };

  config = mkIf config.greetd.enable {
    services.greetd = {
      enable = true;
      restart = true;
      settings = {
        default_session = let
          sessionsList = map (session: "${session}/share/xsessions") config.services.displayManager.sessionPackages;
          sessions = concatStringsSep ":" sessionsList;
        in {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${sessions}";
          user = "greeter";
        };
      };
    };
  };
}