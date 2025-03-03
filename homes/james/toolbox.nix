{ pkgs, ... }:

{
  nixland.windowRules =
    let
      mkFloat =
        name:
        {
          width ? 350,
          height ? 500,
        }:
        [
          {
            class = name;
            rules = [
              "float"
              "size ${toString width} ${toString height}"
            ];
          }
        ];
    in
    mkFloat "io.github.fizzyizzy05.binary" { height = 350; }
    ++ mkFloat "org.gnome.gitlab.cheywood.Buffer" { width = 600; }
    ++ mkFloat "dev.geopjr.Collision" { }
    ++ mkFloat "com.github.huluti.Curtail" { }
    ++ mkFloat "io.gitlab.adhami3310.Impression" { }
    ++ mkFloat "io.github.zefr0x.hashes" { };

  home.packages = with pkgs; [
    binary # Base converter
    buffer # Volatile scratchpad
    collision # Hash calculator
    curtail # Image compressor
    impression # Removable media writer
    gnome-frog # OCR
    hashes # Hash identifier
  ];
}
