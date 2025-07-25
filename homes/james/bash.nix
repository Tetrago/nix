{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    getExe
    mkBefore
    mkEnableOption
    mkIf
    mkMerge
    ;
  inherit (lib.attrsets) mapAttrs;
in
{
  options.james.bash = {
    enable = mkEnableOption "bash configuration.";
  };

  config =
    let
      cfg = config.james.bash;
    in
    mkIf cfg.enable {
      home = {
        file.".blerc".text = ''
          bleopt history_share=1
        '';

        packages = with pkgs; [
          mprocs
          tldr
          xh # CLI HTTP toolkit
          fselect # SQL based find
          p7zip
          jq
          file
        ];
      };

      programs = {
        atuin = {
          enable = true;
          enableBashIntegration = false; # Uses bash-preexec and not ble.sh
          flags = [ "--disable-up-arrow" ];
        };

        bash = {
          enable = true;
          enableCompletion = true;

          sessionVariables = {
            MANPAGER = "sh -c 'col -bx | ${getExe pkgs.bat} -l man -p'";
            MANROFFOPT = "-c";
          };

          shellAliases = with pkgs; {
            ls = "eza";
            ll = "eza -lh";
            la = "eza -alh";
            grep = "grep --color=auto";
            ip = "ip -color=auto";
            cat = "bat -Pu";
            hx = getExe hexyl;
            cp = "cp -i";
            mv = "mv -i";
            nnn = "xplr";
            ranger = "xplr";
            gdb = "gdb -q";
            md = getExe glow;
            math = getExe numbat;
          };

          initExtra = mkMerge [
            ''
              if [[ :$SHELLOPTS: =~ :(vi|emacs): ]]; then
                eval "$(${lib.getExe config.programs.atuin.package} init bash ${lib.escapeShellArgs config.programs.atuin.flags})"
              fi
            ''
            (mkBefore ''
              [[ $- == *i* ]] && source ${pkgs.blesh}/share/blesh/ble.sh
            '')
          ];
        };

        starship = {
          enable = true;
          enableBashIntegration = true;
          settings =
            {
              add_newline = false;
              character = {
                disabled = false;
                error_symbol = "[](bold fg:color_red)";
                success_symbol = "[](bold fg:color_green)";
                vimcmd_replace_one_symbol = "[](bold fg:color_purple)";
                vimcmd_replace_symbol = "[](bold fg:color_purple)";
                vimcmd_symbol = "[](bold fg:color_green)";
                vimcmd_visual_symbol = "[](bold fg:color_yellow)";
              };
              directory = {
                format = "[ $path ]($style)";
                style = "fg:color_fg0 bg:color_yellow";
                substitutions = {
                  Developer = "󰲋 ";
                  Documents = "󰈙 ";
                  Downloads = " ";
                  Music = "󰝚 ";
                  Pictures = " ";
                };
                truncation_length = 3;
                truncation_symbol = "…/";
              };
              docker_context = {
                format = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)";
                style = "bg:color_bg3";
                symbol = "";
              };
              format = "[](color_orange)$username[](bg:color_yellow fg:color_orange)$directory[](fg:color_yellow bg:color_aqua)$git_branch$git_status[](fg:color_aqua bg:color_blue)$c$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:color_blue bg:color_bg3)$docker_context$conda[](fg:color_bg3 bg:color_bg1)[ ](fg:color_bg1)$line_break$character";
              git_branch = {
                format = "[[ $symbol $branch ](fg:color_fg0 bg:color_aqua)]($style)";
                style = "bg:color_aqua";
                symbol = "";
              };
              git_status = {
                format = "[[($all_status$ahead_behind )](fg:color_fg0 bg:color_aqua)]($style)";
                style = "bg:color_aqua";
              };
              line_break.disabled = false;
              os.disabled = true;
              palette = "terminal";
              palettes = {
                terminal = {
                  color_aqua = "6";
                  color_bg1 = "18";
                  color_bg3 = "8";
                  color_blue = "4";
                  color_fg0 = "15";
                  color_green = "2";
                  color_orange = "16";
                  color_purple = "13";
                  color_red = "1";
                  color_yellow = "3";
                };
              };
              time.disabled = true;
              username = {
                format = "[ $user ]($style)";
                show_always = true;
                style_root = "bg:color_orange fg:color_fg0";
                style_user = "bg:color_orange fg:color_fg0";
              };
            }
            // mapAttrs
              (_: v: {
                format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
                style = "bg:color_blue";
                symbol = v;
              })
              {
                c = " ";
                golang = "";
                haskell = "";
                java = " ";
                kotlin = "";
                nodejs = "";
                php = "";
                python = "";
                rust = "";
              };
        };

        bat.enable = true;
        eza.enable = true;
      };
    };
}
