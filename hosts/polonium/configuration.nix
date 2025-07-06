{
  config,
  inputs,
  outputs,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    inputs.home-manager.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index

    outputs.nixosModules.default
    outputs.nixosModules.flume
    outputs.nixosModules.home-manager
  ];

  systemd.network.wait-online.enable = false;

  boot = {
    kernelParams = [
      "plymouth.use-simpledrm"
    ];

    extraModprobeConfig = ''
      options hid_apple swap_opt_cmd=1 swap_fn_leftctrl=1 fnmode=1
      options apple_dcp show_notch=1
    '';

    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 15;
      timeout = 0;
    };

    initrd = {
      enable = true;
      systemd.enable = true; # Needed for plymouth to start quicker
    };
  };

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
    automatic-timezoned.enable = true;
    sysprof.enable = true;
    upower.enable = true;

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${config.services.greetd.package}/bin/agreety --cmd $SHELL";
        };

        initial_session = {
          command = "${pkgs.niri}/bin/niri-session";
          user = "james";
        };
      };
    };

    geoclue2 = {
      enable = true;
      geoProviderUrl = "https://beacondb.net/v1/geolocate";
    };
  };

  tetrago = {
    bluetooth.enable = true;
    fonts.enable = true;
    printing.enable = true;

    plymouth = {
      enable = true;
      theme = {
        name = "asahi";
        package = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "asahi-plymouth";
          version = "0.1";

          src = pkgs.fetchFromGitHub {
            owner = "AsahiLinux";
            repo = pname;
            rev = version;
            hash = "sha256-JgsTiS9Qv+Ct7jRmJMCxbqVNkPahZpX4hFc9RE9aONY=";
          };

          dontBuild = true;

          installPhase = ''
            mkdir -p $out/share/plymouth/themes
            cp -r asahi $out/share/plymouth/themes/asahi
            sed -i "s|/usr|$out|" $out/share/plymouth/themes/asahi/asahi.plymouth
          '';
        };
      };
    };

    users.james = {
      name = "James";
      groups = [ "wheel" ];
    };
  };

  networking = {
    hostName = "polonium";
    firewall.enable = true;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    nftables.enable = true;
  };

  virtualisation.docker.enable = true;

  hardware.asahi = {
    peripheralFirmwareDirectory =
      let
        firmware = pkgs.requireFile {
          name = "mac14g-firmware.tar.gz";
          hash = "sha256-ARVPjv62wUGPQSdSA/cdLHeErVLm/PGO8xw3MCfOisU=";
          message = "This firmware is redistributable only by Apple. Run the store-apple-firmware.sh script.";
        };
      in
      pkgs.runCommand "firmware" { inherit firmware; } ''
        mkdir -p $out
        tar -xzf $firmware -C $out
      '';

    useExperimentalGPUDriver = true;
  };

  home-manager.users.james = import ./home.nix;

  system.stateVersion = "25.11";
}
