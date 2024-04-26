{ config, inputs, pkgs, ... }:

{
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    wl-clipboard
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      exec-once = with pkgs; [
        "wl-paste --type text --watch ${cliphist}/bin/cliphist store"
        "wl-paste --type image --watch ${cliphist}/bin/cliphist store"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "GTK_BACKEND,wayland"
        "GTK_USE_PORTAL,1"
        "NIXOS_OZONE_WL,1"
      ];

      master = {
        new_is_master = "yes";
        mfact = "0.5";
      };

      input = {
        follow_mouse = "yes";
        touchpad.natural_scroll = "yes";
        numlock_by_default = "yes";
        kb_options = "ctrl:nocaps";
      };

      general = {
        gaps_in = "5";
        gaps_out = "5";
        border_size = "1";
        "col.active_border" = "rgba(eff1f5ee) rgba(bbbfcbee) 45deg";
        "col.inactive_border" = "rgba(4b4e69aa)";
        layout = "master";
      };
      
      gestures = {
        "workspace_swipe" = "yes";
        "workspace_swipe_create_new" = "no";
      };

      decoration = {
        rounding = "5";
        blur.enabled = "yes";
        blur.size = "3";
        blur.passes = "1";
        drop_shadow = "yes";
        shadow_range = "4";
        shadow_render_power = "3";
        "col.shadow" = "rgba(1a1a1aee)";
      };

      misc = {
        new_window_takes_over_fullscreen = 2;
        disable_hyprland_logo = "yes";
        disable_splash_rendering = "yes";
        vfr = "yes";
      };

      "$mod" = "SUPER";

      bind = let 
        hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
        thunar = "${pkgs.xfce.thunar}/bin/thunar";
        cliphist = "${pkgs.cliphist}/bin/cliphist";
        jq = "${pkgs.jq}/bin/jq";
        brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        slurp = "${pkgs.slurp}/bin/slurp";
        grim = "${pkgs.grim}/bin/grim";
        swappy = "${pkgs.swappy}/bin/swappy";
        find = pkgs.writeShellScriptBin "findWindows" ''hyprctl clients -j | ${jq} -r ".[]" | ${jq} -r ".at,.size" | ${jq} -s "add" | ${jq} '_nwise(4)' | ${jq} -r '"\(.[0]),\(.[1]) \(.[2])x\(.[3])"' | ${slurp} -r'';
      in with pkgs; [
        "$mod, Return, exec, kitty"
        "$mod, C, exec, ${inputs.ags.packages.${pkgs.system}.ags}/bin/ags -b hypr -t system_center"
        "$mod SHIFT, C, exec, pid of ${hyprpicker} || ${hyprpicker} -a"
        "$mod, W, killactive"
        "$mod, E, exec, ${thunar}"
        "$mod, L, exec, loginctl lock-session"
        "$mod, V, exec, pidof ${cliphist} || ${cliphist} list | wofi --dmenu | ${cliphist} decode | wl-copy"
        "$mod, F, togglefloating"
        "$mod, Space, exec, pidof wofi || wofi --show drun"
        "$mod, Tab, hyprexpo:expo, toggle"
        ", Print, exec, pidof ${slurp} || ${grim} -g \"$(${slurp} -o -r)\" - | ${swappy} -f -"
        "ALT, Print, exec, pidof ${slurp} || ${grim} -g \"$(${find}/bin/findWindows)\" - | ${swappy} -f -"
        "$mod SHIFT, S, exec, pidof ${slurp} || ${grim} -g \"$(${slurp})\" - | ${swappy} -f -"
        "$mod SHIFT, Z, movetoworkspace, special"
        "$mod, Z, togglespecialworkspace"
        "$mod SHIFT, Space, fullscreen, 1"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, M, exec, hyprctl dispatch layoutmsg swapwithmaster"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        ", XF86MonBrightnessUp, exec, ${brightnessctl} set +10%"
        ", XF86MonBrightnessDown, exec, ${brightnessctl} set 10%-"
        ", XF86AudioPlay, exec, ${playerctl} play-pause"
        ", XF86AudioStop, exec, ${playerctl} stop"
        ", XF86AudioPrev, exec, ${playerctl} previous"
        ", XF86AudioNext, exec, ${playerctl} next"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      binde = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      windowrulev2 = [
        "float,class:(feh)"
        "size 0 0,class:(ghidra-Ghidra),title:(Ghidra)"
        "center,class:(ghidra-Ghidra),title:(Ghidra)"
        "tile,class:(ghidra-Ghidra),title:^(Ghidra: )"
        "tile,class:(ghidra-Ghidra),title:(CodeBrowser)"
        "tile,title:^(Burp Suite Community Edition)"
      ];

      plugin = {
        hyprexpo = {
          columns = 3;
          gap_size = 5;
          bg_col = "rgb(${config.colorScheme.palette.base00})";
          workspace_method = "center first";

          enable_gesture = true;
          gesture_distance = 300;
          gesture_positive = false;
        };
      };
    };

    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    
    plugins = with inputs.hyprland-plugins.packages.${pkgs.system}; [
      hyprexpo
    ];
  };
}
