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
  options.tetrago.cyber = {
    enable = mkEnableOption "enable cyber programs";
  };

  config = mkIf config.tetrago.cyber.enable {
    home = {
      file =
        {
        };

      packages = with pkgs; [
        binaryninja
        burpsuite
        ghidra-bin
      ];
    };
  };
}
