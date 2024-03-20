{ colors }:

{
  enable = true;
  settings.mainBar = {
    layer = "top";
    modules-left = [ "hyprland/workspaces" ]; 
    modules-center = [ "clock" ];
    modules-right = [ "cpu" "memory" "battery" "tray" ];
    "hyprland/window".max-length = 50;
    "hyprland/workspaces" = {
      format = "{icon}";
      format-icons = {
        active = "";
        empty = "";
        default = "";
        special = "󰻂";
        urgent = "";
      };
    };
    cpu = {
      format = "{icon}";
      format-icons = [ "󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥" ];
    };
    memory = {
      format = "{icon}";
      format-icons = [ "󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥" ];
    };
    battery = {
      format = "{icon}";
      format-icons = [ " " " " " " " " " " ];
      tooltip-format = "{capacity}%";
    };
    clock = {
      format = "{:%I:%M}";
      tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "month";
              format = {
                months = "<span color='#6c6f85'><b>{}</b></span>";
                weekdays = "<span color='#6c6f85'><b>{}</b></span>";
                days = "<span color='#7c7f93'><b>{}</b></span>";
                today = "<span color='#4c4f69'><b>{}</b></span>";
              };
            };
    };
    tray = {
      icon-size = 15;
      spacing = 8;
    };
  };
  style = ''
    * { color: #${colors.base05}; }
    window#waybar { background: none; }
    tooltip { background-color: alpha(#${colors.base00}, 0.8); }

    .modules-left, .modules-center, .modules-right {
      background-color: alpha(#${colors.base00}, 0.8);
      padding: 0 10px;
      margin: 5px 5px 0 5px;
      border-radius: 20px;
    }

    #cpu, #memory, #battery, #tray { padding: 0 10px; }

    #cpu {
      background-color: alpha(#${colors.base0D}, 0.1);
      padding-right: 14px;
    }

    #memory {
      background-color: alpha(#${colors.base0B}, 0.1);
      padding-right: 14px;
    }

    #battery {
      background-color: alpha(#${colors.base08}, 0.1);
      padding-right: 10px;
    }

    #workspaces button {
      border: none;
      border-radius: 0;
      background: none;
      padding: 0 0.3em 0 0;
    }
  '';
}