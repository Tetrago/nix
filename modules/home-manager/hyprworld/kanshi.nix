{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.attrsets) mapAttrs mergeAttrsList optionalAttrs;
  inherit (lib.lists) optionals;
  inherit (lib.strings) optionalString;

  monitors = mergeAttrsList [
    { default = config.hyprworld.monitors; }
    config.hyprworld.additionalMonitors
  ];

  mapMonitorToOutput =
    m:
    mergeAttrsList (
      [
        {
          criteria = m.name;
          status = if m.enable then "enable" else "disable";
        }
      ]
      ++ optionals m.enable [
        (optionalAttrs (m.resolution != null) (
          with m.resolution;
          {
            mode = "${toString width}x${toString height}${
              optionalString (refreshRate != null) "@${toString refreshRate}"
            }";
          }
        ))
        (optionalAttrs (m.position != null) (
          with m.position; { position = "${toString x},${toString y}"; }
        ))
        (optionalAttrs (m.scale != null) { inherit (m) scale; })
      ]
    );

  mapMonitorsToExec =
    list:
    map (
      m:
      optionalString (
        m.workspace != null
      ) "hyprctl dispatch moveworkspacetomonitor ${toString m.workspace} ${m.name}"
    ) list;

  mapMonitorsToProfile = list: {
    exec = [
      "systemctl --user restart ags.service swww.service"
    ] ++ (builtins.filter (v: v != "") (mapMonitorsToExec list));
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
