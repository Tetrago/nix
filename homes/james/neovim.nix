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
            };
        })
      ];
    };
}
