{ pkgs, ... }:

{
  wayland.windowManager.hyprland.settings.windowrulev2 =
    let
      mkFloat = name: [
        "float,class:^(${name})$"
        "size 350 500,class:^(${name})$"
      ];
    in
    [
      "float,class:^(io.github.fizzyizzy05.binary)$"
      "size 350 350,class:^(io.github.fizzyizzy05.binary)$"
    ]
    ++ mkFloat "org.gnome.gitlab.cheywood.Buffer"
    ++ mkFloat "dev.geopjr.Collision"
    ++ mkFloat "com.github.huluti.Curtail"
    ++ mkFloat "io.gitlab.adhami3310.Impression"
    ++ mkFloat "io.github.zefr0x.hashes";

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
