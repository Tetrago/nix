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
      file = {
        ".gdbinit".text = "source ${pkgs.gef}/share/gef/gef.py";

        ".config/pwn.conf".text = ''
          [context]
          terminal=["${config.programs.kitty.package}/bin/kitty", "sh", "-c"]
        '';
      };

      packages = with pkgs; [
        binaryninja
        burpsuite
        ghidra-bin
      ];
    };
  };
}
