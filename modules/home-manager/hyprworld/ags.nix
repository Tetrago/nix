{ inputs, pkgs, ... }:

{
  systemd.user.services.ags = import ./service.nix pkgs "${inputs.ags.packages.${pkgs.system}.ags}/bin/ags -b hypr -c ${./ags}/config.js";
}