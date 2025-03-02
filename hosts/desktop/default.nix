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
    geoclue2 = {
      enable = true;
      geoProviderUrl = "https://beacondb.net/v1/geolocate";
    };

    speechd.enable = true;
  };

  tetrago = {
    audio.enable = true;
    boot.enable = true;
    fonts.enable = true;
    hyprland.enable = true;
    networking.enable = true;
    plymouth.enable = true;
    printing.enable = true;

    sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;

      theme = {
        name = "sddm-astronaut-theme";
        package = pkgs.sddm-astronaut.override {
          themeConfig = {
            Font = "Ubuntu Sans";
            HourFormat = "hh:mm AP";
            DateFormat = "dddd, MMMM d";
            Background = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/3a24624d04aedc638e042a1de81238b95b46a342/Wallpaper-nord/WhiteSur-nord-light.png";
              sha256 = "sha256-jcX00tiPje0YGe38y0Vr0FA5Mg21XpHYp4m6ptx2iAw=";
            };
            DimBackground = "0.3";
            PartialBlur = "false";
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
      username = "james";
      name = "James";
      groups = [
        "wheel"
        "docker"
        "libvirtd"
        "kvm"
        "networkmanager"
      ];
    };
  };
}
