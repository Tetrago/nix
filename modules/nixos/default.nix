{ outputs, ... }:

{
  imports = [
    ./bluetooth.nix
    ./fonts.nix
    ./greetd.nix
    ./hyprland.nix
    ./net.nix
    ./nvidia.nix
    ./opengl.nix
    ./pipewire.nix
    ./plymouth.nix
    ./secureboot.nix
    ./steam.nix
    ./usrs.nix
    ./virt.nix
  ];

  config = {
    nix = {
      settings.experimental-features = [ "nix-command" "flakes" ];
      extraOptions = "warn-dirty = false";
    };

    nixpkgs = {
      overlays = [ outputs.overlays.default ];
      config.allowUnfree = true;
    };

    i18n.defaultLocale = "en_US.UTF-8";
  };
}
