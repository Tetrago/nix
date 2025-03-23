{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
in
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  options.james.neovim = {
    enable = mkEnableOption "neovim configuration.";
    transparent = mkEnableOption "transparent neovim.";
    enableDarkmanIntegration = mkEnableOption "darkman integration for neovim.";
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
              imports = [ (import ../../modules/nixvim/wondervim) ];

              wondervim = {
                enable = true;
                inherit (cfg) transparent enableDarkmanIntegration;
              };
            };
        })
      ];
    };
}
