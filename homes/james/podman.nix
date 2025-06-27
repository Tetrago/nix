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
  options.james.podman = {
    enable = mkEnableOption "podman configuration.";
    enableGui = mkEnableOption "podman GUI.";
  };

  config =
    let
      cfg = config.james.podman;
    in
    mkIf cfg.enable {
      home = {
        packages = with pkgs; [
          dive
          (mkIf cfg.enableGui pods)
        ];

        sessionVariables = {
          PODMAN_COMPOSE_PROVIDER = lib.getExe pkgs.podman-compose;
          PODMAN_COMPOSE_WARNING_LOGS = "false";
        };
      };

      services.podman.enable = true;

      xdg.configFile = {
        "systemd/user/default.target.wants/podman.socket".source =
          "${config.services.podman.package}/share/systemd/user/podman.socket";

        "pods/connections.json".text = ''
          {
            "bdc91fa5-b203-409b-a391-90c0e2de60eb": {
              "uuid": "bdc91fa5-b203-409b-a391-90c0e2de60eb",
              "name": "localhost",
              "url": "unix:///run/user/1000/podman/podman.sock",
              "rgb": null
            }
          }
        '';
      };
    };
}
