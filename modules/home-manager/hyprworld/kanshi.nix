{ host, lib, ... }:

let
  mapOutputs = let inherit (lib) mkIf optional; in configuration: map (m:
    {
      criteria = m.name;
      status = if m.enable then "enable" else "disable";
      mode = if m.enable && !(isNull m.width) && !(isNull m.height) then "${toString m.width}x${toString m.height}${lib.strings.optionalString (!(isNull m.refreshRate)) "@${toString m.refreshRate}"}" else null;
      position = if m.enable && !(isNull m.position) then "${toString m.position.x},${toString m.position.y}" else null;
      scale = m.scale;
    }
  ) configuration;

  mapProfiles = configurations: builtins.listToAttrs (map (c:
    {
      name = c.name;
      value = {
        exec = "systemctl --user restart ags.service hyprpaper.service";
        outputs = mapOutputs c.configuration;
      };
    }
  ) configurations);
in
{
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    profiles = mapProfiles (
      [
        {
          name = "default";
          configuration = host.configurations.default;
        }
      ] ++ host.configurations.others
    );
  };
}