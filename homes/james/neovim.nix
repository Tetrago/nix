{
  config,
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
in
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  options.james.neovim = {
    enable = mkEnableOption "neovim configuration.";
    transparent = mkEnableOption "transparent neovim.";
    enableThemeIntegration = mkEnableOption "darkman integration for neovim.";
  };

  config =
    let
      cfg = config.james.neovim;
    in
    mkIf cfg.enable {
      home.packages = [
        (inputs.nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvimWithModule {
          inherit pkgs;

          module =
            { ... }:
            {
              imports = [ outputs.nixvimModules.wondervim ];

              wondervim = {
                enable = true;
                inherit (cfg) transparent enableThemeIntegration;
              };

              plugins.avante = {
                enable = true;
                settings = {
                  provider = "ollama";
                  providers.ollama = {
                    endpoint = "http://192.168.122.50:11434";
                    model = "qwq:32b";
                    is_env_set.__raw = ''require("avante.providers.ollama").check_endpoint_alive'';
                  };
                };
              };
            };
        })
      ];
    };
}
