{
  james =
    {
      config,
      outputs,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ ../../homes/james/desktop ];

      home.packages = with pkgs; [
        alpaca
      ];
    };
}
