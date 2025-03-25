{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkForce
    mkIf
    ;
in
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  options.tetrago.boot = {
    enable = mkEnableOption "boot configuration handler.";

    loader = mkOption {
      type = types.enum [
        "systemd"
        "grub"
      ];
      default = "systemd";
    };

    skipBootMenu = mkOption {
      type = types.bool;
      default = true;
    };

    secureboot = {
      enable = mkEnableOption "enable secureboot.";
      tpm2.enable = mkEnableOption "enable tpm2 support.";
    };
  };

  config =
    let
      cfg = config.tetrago.boot;
    in
    mkIf cfg.enable {
      assertions = [
        {
          assertion = !(cfg.loader == "grub" && cfg.secureboot.enable);
          message = "Secureboot requires systemd-boot";
        }
      ];

      boot = {
        loader = {
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot/efi";
          };

          systemd-boot = {
            enable = mkForce (if cfg.loader == "systemd" then !cfg.secureboot.enable else false);
            configurationLimit = 15;
          };

          grub =
            let
              theme = inputs.distro-grub-themes.packages.${pkgs.stdenv.hostPlatform.system}.nixos-grub-theme;
            in
            {
              enable = mkForce (cfg.loader == "grub");
              configurationLimit = 15;
              efiSupport = true;
              device = "nodev";
              theme = mkIf (cfg.loader == "grub") theme;
              splashImage = mkIf (cfg.loader == "grub") "${theme}/splash_image.jpg";
            };

          timeout = mkIf cfg.skipBootMenu 0;
        };

        lanzaboote = mkIf cfg.secureboot.enable {
          enable = true;
          pkiBundle = "/etc/secureboot";
        };

        initrd.systemd = {
          enable = true;
          tpm2.enable = cfg.secureboot.enable && cfg.secureboot.tpm2.enable;
        };
      };
    };
}
