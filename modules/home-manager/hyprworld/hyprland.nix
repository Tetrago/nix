{ pkgs }:

let
  startup = pkgs.writeShellScriptBin "hyprworldStartScript" ''
    ${pkgs.swaynotificationcenter}/bin/swaync &
    ${pkgs.wl-clipboard}/bin/wl-paste --type text --watch cliphist store &
    ${pkgs.wl-clipboard}/bin/wl-paste --type image --watch cliphist store &
    ${pkgs.hyprpaper}/bin/hyprpaper &
    ${pkgs.hypridle}/bin/hypridle &
  '';
in
{
  enable = true;
  settings = {
    exec-once = "${startup}/bin/hyprworldStartScript";
    env = [
      "XCURSOR_SIZE,24"
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_TYPE,wayland"
      "XDG_SESSION_DESKTOP,Hyprland"
      "QT_QPA_PLATFORM,wayland;xcb"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      "_JAVA_AWT_WM_NONREPARENTING,1"
      "GTK_BACKEND,wayland"
      "MOZ_ENABLE_WAYLAND,1"
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
      disable_hyprland_logo = "yes";
      disable_splash_rendering = "yes";
      vfr = "yes";
    };
    "$mod" = "SUPER";
    bind = [
      "$mod, Return, exec, alacritty"
      "$mod, C, exec, swaync-client -t -sw"
      "$mod SHIFT, C, exec, hyprpicker -a"
      "$mod, W, killactive"
      "$mod, E, exec, pcmanfm"
      "$mod, Q, exec, nwg-bar"
      "$mod, L, exec, loginctl lock-session"
      "$mod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"
      "$mod, F, togglefloating"
      "$mod, Space, exec, wofi --show drun"
      ", Print, exec, grim -g \"$(slurp)\" - | swappy -f -"
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

      ", XF86MonBrightnessUp, exec, brightnessctl -e set +10%"
      ", XF86MonBrightnessDown, exec, brightnessctl -e set 10%-"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioStop, exec, playerctl stop"
      ", XF86AudioPrev, exec, playerctl previous"
      ", XF86AudioNext, exec, playerctl next"
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
      "size 0 0,class:(ghidra-Ghidra),title:(Ghidra)"
      "center,class:(ghidra-Ghidra),title:(Ghidra)"
      "tile,class:(ghidra-Ghidra),title:^(Ghidra: )"
      "tile,class:(ghidra-Ghidra),title:(CodeBrowser)"
      "tile,title:^(Burp Suite Community Edition)"
    ];
  };
}
