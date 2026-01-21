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
    outputs.nixosModules.garden
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

  services.fwupd.enable = true;

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

  environment.etc.hosts.mode = "0644";
}
