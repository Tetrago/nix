{ config, ... }:

let
  colors = config.colorScheme.palette;
in
{
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      width = 750;
      height = 400;
      always_parse_args = true;
      show_all = false;
      print_command = true;
      insensitive = true;
      prompt = " Hmm, what do you want to run?";
    };
    style = ''
      window {
        margin: 0px;
        border: 1px solid #${colors.base02};
        background-color: #${colors.base00};
      }

      #input {
        margin: 5px;
        border: none;
        color: #${colors.base05};
        background-color: #${colors.base01};
      }

      #inner-box, #outer-box {
        margin: 5px;
        border: none;
        background-color: #${colors.base00};
      }

      #scroll {
        margin: 0px;
        border: none;
      }

      #text {
        margin: 5px;
        border: none;
        color: #${colors.base05};
      }

      #entry:selected {
        border: 1px solid #${colors.base01};
      }
    '';
  };
}
