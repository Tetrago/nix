{
  inputs,
  outputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index

    outputs.nixosModules.default
    outputs.nixosModules.home-manager
    outputs.nixosModules.hyprworld
  ];

  environment.systemPackages = with pkgs; [
    system-config-printer # Printer gui
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  programs = {
    command-not-found.enable = false;
    nix-index-database.comma.enable = true;

    nh = {
      enable = true;
      flake = "/etc/nixos";
    };
  };

  security.polkit.enable = true;

  services = {
    fwupd.enable = true;
    printing.drivers = with pkgs; [ epson-escpr ];
    speechd.enable = true;
    sysprof.enable = true;
    automatic-timezoned.enable = true;

    geoclue2 = {
      enable = true;
      geoProviderUrl = "https://beacondb.net/v1/geolocate";
    };
  };

  fonts.packages = with pkgs; [
    adwaita-fonts
  ];

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  tetrago = {
    audio.enable = true;
    boot.enable = true;
    fonts.enable = true;
    hyprland.enable = true;
    plymouth.enable = true;
    printing.enable = true;

    sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;

      theme = {
        name = "sddm-astronaut-theme";
        package = pkgs.sddm-astronaut.override {
          themeConfig =
            let
              path = ./sddm.jpg;
              colors = import (
                outputs.lib.mkColors {
                  inherit pkgs path;
                  style = "light";
                }
              );
            in
            {
              Font = "Adwaita Sans";
              HourFormat = "hh:mm AP";
              DateFormat = "dddd, MMMM d";
              Background = "${path}";
              DimBackground = "0.3";
              PartialBlur = "false";

              HeaderTextColor = "#${colors.base05}";
              DateTextColor = "#${colors.base05}";
              TimeTextColor = "#${colors.base05}";

              FormBackgroundColor = "#${colors.base00}";
              BackgroundColor = "#${colors.base00}";
              DimBackgroundColor = "#${colors.base00}";

              LoginFieldBackgroundColor = "#${colors.base01}";
              PasswordFieldBackgroundColor = "#${colors.base01}";
              LoginFieldTextColor = "#${colors.base05}";
              PasswordFieldTextColor = "#${colors.base05}";
              UserIconColor = "#${colors.base05}";
              PasswordIconColor = "#${colors.base05}";

              PlaceholderTextColor = "#${colors.base04}";
              WarningColor = "#${colors.base02}";

              LoginButtonTextColor = "#${colors.base05}";
              LoginButtonBackgroundColor = "#${colors.base02}";
              SystemButtonsIconsColor = "#${colors.base06}";
              SessionButtonTextColor = "#${colors.base06}";
              VirtualKeyboardButtonTextColor = "#${colors.base06}";

              DropdownTextColor = "#${colors.base05}";
              DropdownSelectedBackgroundColor = "#${colors.base02}";
              DropdownBackgroundColor = "#${colors.base00}";

              HighlightTextColor = "#${colors.base04}";
              HighlightBackgroundColor = "#${colors.base02}";
              HighlightBorderColor = "#${colors.base02}";

              HoverUserIconColor = "#${colors.base0D}";
              HoverPasswordIconColor = "#${colors.base0D}";
              HoverSystemButtonsIconsColor = "#${colors.base0D}";
              HoverSessionButtonTextColor = "#${colors.base0D}";
              HoverVirtualKeyboardButtonTextColor = "#${colors.base0D}";
            };
        };
        extraPackages = with pkgs.kdePackages; [
          qtmultimedia
          qtsvg
          qtvirtualkeyboard
        ];
      };
    };

    users.james = {
      name = "James";
      groups = [
        "wheel"
        "docker"
        "libvirtd"
        "kvm"
        "networkmanager"
        "lpadmin"
      ];
    };
  };
}
