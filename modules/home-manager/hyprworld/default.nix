{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    ./ags.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./kanshi.nix
    ./wofi.nix
  ];

  home = {
    packages = with pkgs; [
      gnome.file-roller
      networkmanagerapplet
    ];
  };

  programs = {
    feh = {
      enable = true;
      buttons = {
        prev_img = "";
        next_img = "";
        zoom_in = 4;
        zoom_out = 5;
      };
    };

    zathura.enable = true;
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
      config.hyprland.default = [ "hyprland" "gtk" ];
      extraPortals = [
        (inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland.override {
          hyprland = config.wayland.windowManager.hyprland.finalPackage;
        })
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };
}
