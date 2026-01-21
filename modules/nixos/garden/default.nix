{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) any;
  inherit (lib) mkIf mkMerge;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) flatten;
in
{
  config = mkMerge [
    {
      nixpkgs.overlays = [
        (self: super: {
          nautilus = super.nautilus.overrideAttrs (
            final: prev: {
              nativeBuildInputs = prev.nativeBuildInputs or [ ] ++ [
                pkgs.makeWrapper
              ];

              preFixup = prev.preFixup or "" + ''
                gappsWrapperArgs+=(
                  --prefix XDG_DATA_DIRS : "${pkgs.ffmpegthumbnailer}/share"
                )
              '';
            }
          );
        })
      ];
    }
    (mkIf
      (any (x: x.enable) (
        mapAttrsToList (_: x: x.garden or { enable = false; }) config.home-manager.users
      ))
      {
        environment = {
          gnome.excludePackages = with pkgs; [
            baobab
            cheese
            epiphany
            geary
            gnome-contacts
            gnome-maps
            gnome-music
            gnome-photos
            gnome-tour
            gnome-user-docs
            seahorse
            simple-scan
            yelp
          ];

          systemPackages = flatten (
            mapAttrsToList (_: v: v.garden.extensions or [ ]) config.home-manager.users
          );
        };

        services = {
          desktopManager.gnome.enable = true;
          displayManager.gdm.enable = true;
          gnome.core-developer-tools.enable = false;
          sysprof.enable = true;
          upower.enable = true;
        };
      }
    )
  ];
}
