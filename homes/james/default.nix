{ inputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  users.users.james = {
    isNormalUser = true;
    description = "James";

    createHome = true;
    home = "/home/james";

    shell = pkgs.bashInteractive;
    extraGroups = [ "wheel" "docker" "libvirtd" ];
  };

  programs.hyprland.enable = true;
  services.gvfs.enable = true; # Trash

  home-manager.users.james = import ./home.nix;
}
