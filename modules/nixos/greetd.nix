{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.strings) concatStringsSep;
in {
  options.tetrago.greetd = { enable = mkEnableOption "enable greetd"; };

  config = mkIf config.tetrago.greetd.enable {
    services.greetd = {
      enable = true;
      restart = true;
      settings = {
        default_session = let
          sessions = concatStringsSep ":"
            (map (session: "${session}/share/xsessions")
              config.services.displayManager.sessionPackages);
        in {
          command =
            "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${sessions}";
          user = "greeter";
        };
      };
    };
  };
}
