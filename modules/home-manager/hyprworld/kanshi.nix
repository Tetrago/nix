{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.attrsets) mapAttrs mergeAttrsList optionalAttrs;
  inherit (lib.lists) optional;
  inherit (lib.strings) optionalString;

  monitors = mergeAttrsList [
    { default = config.hyprworld.monitors; }
    config.hyprworld.additionalMonitors
  ];

  mapMonitorToOutput = m: mergeAttrsList [
    {
      criteria = m.name;
      status = m.enable;
    }
  ] ++ optional m.enable [
    (optionalAttrs m.resoltion != null (with m.resoltion; {
      mode = "${width}x${height}${optionalString refreshRate != null "@${refreshRate}"}";
    }))
    (optionalAttrs m.posiition != null (with m.position; { position = "${x},${y}"; }))
    (optionalAttrs m.scale != null { inherit (m) scale; })
  ];

  mapMonitorsToProfile = list: {
    exec = "systemctl --user restart ags.service hyprpaper.service";
    outputs = map mapMonitorToOutput list;
  };
in
{
  services.kanshi = mkIf (config.hyprworld.additionalMonitors != null) {
    enable = true;
    systemdTarget = "hyprland-session.target";
    profiles = mapAttrs (_: value: mapMonitorsToProfile value) monitors;
  };
}