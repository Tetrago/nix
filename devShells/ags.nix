{
  libadwaita,
  pkgs,
  mkShell,
  ags,
}:

mkShell {
  packages = [
    (ags.packages.${pkgs.system}.default.override {
      extraPackages = with ags.packages.${pkgs.system}; [
        libadwaita
        tray
        wireplumber
        hyprland
        battery
        notifd
      ];
    })
  ];
}
