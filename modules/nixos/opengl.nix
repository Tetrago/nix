{ config, lib, ... }:

{
  options.opengl = {
    enable = lib.mkEnableOption "enable OpenGL support";
  };

  config = lib.mkIf config.opengl.enable {
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };
}
