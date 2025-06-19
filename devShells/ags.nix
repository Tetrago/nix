{
  libadwaita,
  pkgs,
  mkShell,
  ags,
}:

mkShell {
  packages = [
    (ags.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      extraPackages = with ags.packages.${pkgs.stdenv.hostPlatform.system}; [
        libadwaita
        tray
        wireplumber
        hyprland
        battery
      ];
    })
  ];
}
