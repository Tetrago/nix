{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./ags.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./services.nix
    ./theme.nix
    ./kanshi.nix
    ./walker.nix
  ];

  home = {
    packages = with pkgs; [
      networkmanagerapplet # Necessary despite services.network-manager-applet.enable being set to true
    ];
  };

  services = {
    blueman-applet.enable = config.hyprworld.bluetooth;
    mpris-proxy.enable = true;
    network-manager-applet.enable = true;

    udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };
  };

  xdg = {
    portal = {
      enable = true;

      config = {
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];

          "org.freedesktop.impl.portal.Settings" = [
            "darkman"
            "gtk"
          ];
        };
      };

      extraPortals = [
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
        pkgs.darkman
      ];
    };
  };
}
