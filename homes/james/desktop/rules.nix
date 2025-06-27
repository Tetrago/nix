{ ... }:

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
    [
      {
        class = "ghidra-Ghidra";
        title = "Ghidra";
        rules = "size 0 0";
      }
      {
        class = "ghidra-Ghidra";
        title = "Ghidra:.*";
        rules = "tile";
      }
      {
        class = "ghidra-Ghidra";
        title = "CodeBrowser";
        rules = "tile";
      }
      {
        title = "OpenTTD.*";
        rules = "tile";
      }
      {
        class = "Aseprite";
        rules = "tile";
      }
    ]
    ++ mkFloat "io.github.fizzyizzy05.binary" { height = 350; }
    ++ mkFloat "org.gnome.gitlab.cheywood.Buffer" { width = 600; }
    ++ mkFloat "dev.geopjr.Collision" { }
    ++ mkFloat "com.github.huluti.Curtail" { }
    ++ mkFloat "io.gitlab.adhami3310.Impression" { }
    ++ mkFloat "io.github.zefr0x.hashes" { };
}
