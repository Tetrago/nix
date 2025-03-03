{
  ...
}:

{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      "add_newline" = false;
      "c" = {
        "format" = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        "style" = "bg:color_blue";
        "symbol" = " ";
      };
      "character" = {
        "disabled" = false;
        "error_symbol" = "[](bold fg:color_red)";
        "success_symbol" = "[](bold fg:color_green)";
        "vimcmd_replace_one_symbol" = "[](bold fg:color_purple)";
        "vimcmd_replace_symbol" = "[](bold fg:color_purple)";
        "vimcmd_symbol" = "[](bold fg:color_green)";
        "vimcmd_visual_symbol" = "[](bold fg:color_yellow)";
      };
      "directory" = {
        "format" = "[ $path ]($style)";
        "style" = "fg:color_fg0 bg:color_yellow";
        "substitutions" = {
          "Developer" = "󰲋 ";
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = "󰝚 ";
          "Pictures" = " ";
        };
        "truncation_length" = 3;
        "truncation_symbol" = "…/";
      };
      "docker_context" = {
        "format" = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)";
        "style" = "bg:color_bg3";
        "symbol" = "";
      };
      "format" =
        "[](color_orange)$username[](bg:color_yellow fg:color_orange)$directory[](fg:color_yellow bg:color_aqua)$git_branch$git_status[](fg:color_aqua bg:color_blue)$c$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:color_blue bg:color_bg3)$docker_context$conda[](fg:color_bg3 bg:color_bg1)[ ](fg:color_bg1)$line_break$character";
      "git_branch" = {
        "format" = "[[ $symbol $branch ](fg:color_fg0 bg:color_aqua)]($style)";
        "style" = "bg:color_aqua";
        "symbol" = "";
      };
      "git_status" = {
        "format" = "[[($all_status$ahead_behind )](fg:color_fg0 bg:color_aqua)]($style)";
        "style" = "bg:color_aqua";
      };
      "golang" = {
        "format" = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        "style" = "bg:color_blue";
        "symbol" = "";
      };
      "haskell" = {
        "format" = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        "style" = "bg:color_blue";
        "symbol" = "";
      };
      "java" = {
        "format" = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        "style" = "bg:color_blue";
        "symbol" = " ";
      };
      "kotlin" = {
        "format" = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        "style" = "bg:color_blue";
        "symbol" = "";
      };
      "line_break" = {
        "disabled" = false;
      };
      "nodejs" = {
        "format" = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        "style" = "bg:color_blue";
        "symbol" = "";
      };
      "os" = {
        "disabled" = true;
      };
      "palette" = "base16";
      "palettes" = {
        "base16" = {
          "color_aqua" = "6";
          "color_bg1" = "18";
          "color_bg3" = "8";
          "color_blue" = "4";
          "color_fg0" = "15";
          "color_green" = "2";
          "color_orange" = "16";
          "color_purple" = "13";
          "color_red" = "1";
          "color_yellow" = "3";
        };
      };
      "php" = {
        "format" = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        "style" = "bg:color_blue";
        "symbol" = "";
      };
      "python" = {
        "format" = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        "style" = "bg:color_blue";
        "symbol" = "";
      };
      "rust" = {
        "format" = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        "style" = "bg:color_blue";
        "symbol" = "";
      };
      "time" = {
        "disabled" = true;
      };
      "username" = {
        "format" = "[ $user ]($style)";
        "show_always" = true;
        "style_root" = "bg:color_orange fg:color_fg0";
        "style_user" = "bg:color_orange fg:color_fg0";
      };
    };
  };
}
