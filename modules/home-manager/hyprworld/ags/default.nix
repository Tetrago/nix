{
  ags,
  pkgs,
  libadwaita,
}:

ags.lib.bundle {
  inherit pkgs;
  src = ./.;
  name = "hyprworld-shell";
  entry = "app.ts";
  gtk4 = true;

  extraPackages =
    (with ags.packages.${pkgs.stdenv.hostPlatform.system}; [
      tray
      wireplumber
      hyprland
      battery
      notifd
    ])
    ++ [
      libadwaita
    ];
}
