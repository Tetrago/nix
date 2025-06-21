{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkForce mkIf;
in
{
  options.james.neovide = {
    enable = mkEnableOption "Neovide configuration.";
  };

  config =
    let
      cfg = config.james.neovide;
    in
    mkIf cfg.enable {
      programs.neovide = {
        enable = true;
        settings = {
          neovim-bin = lib.getExe (
            inputs.nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvimWithModule {
              inherit pkgs;

              module =
                { ... }:
                {
                  imports = [ (import ../../modules/nixvim/wondervim) ];

                  globals = {
                    direnv_silent_load = 1;
                    neovide_padding_top = 5;
                    neovide_padding_bottom = 5;
                    neovide_padding_right = 5;
                    neovide_padding_left = 5;
                  };

                  opts = {
                    laststatus = 3; # For incline
                    hidden = true; # For toggleterm
                  };

                  autoCmd = [
                    {
                      event = [ "TermOpen" ];
                      pattern = "term://*";
                      callback.__raw = ''
                        function()
                          local opts = {buffer = 0}
                          vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
                          vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
                        end
                      '';
                    }
                  ];

                  plugins = {
                    auto-session.settings.suppressed_dirs = [ config.home.homeDirectory ];
                    direnv.enable = true;
                    image.enable = mkForce false;
                    neoscroll.enable = mkForce false;

                    snacks.settings.dashboard = {
                      enabled = true;
                      preset.header = ''
                                                                                                         ':!<_???_>^     
                                                                                                    `!-1/jrxxjt|||((?    
                                                                                                ^<{tjjt|){}}1rUUnjt1/,   
                                                                                             !}tjt|((/jnvvvr{:,r0vrt|:   
                                                                                         '~)ff//rcCmpkhhhhaaoh_ YLxt|    
                                                                                      `_|jffxX0qddpwmZZZmwqpqaw nLrj<    
                                                                                   .+|jjrvLwdpwZ0QLLCJL0ZZmpphQ`LXr1     
                                                                                 i(rrxz0pdqOCXnf|)1|nYYJQZmpp#[[Ont      
                                                                              :{jxnz0pdmCu|?!,'     ^]YYLZmqoC!0cf'      
                                                                            +fnncQqpmYf?;'         . `uJQZwhp>UYf'       
                                                                ',l>~-?_~?/vzXCwpmUt<`               :XCZZkd-zC/         
                                                            ^!+?}{1))[]1rcYCZpwCn1+!l:'              )L0Zkp?cL1          
                                                         ,>?}{)(||(}}/uXCOqpOzt}?]{(()}_;           +CQZhO[XJ-           
                                                      .!-}{)(|/t|{1jcULmpwCn({)jvXYXvxf|1?l        >JQmaU{CzI            
                                                    .i?{1(|/tf|1(xXC0qpZYr||nCmqwZLUXcnj/)}-:     ~JQqkx|Qt              
                                                   !?})(/tff|1|uYLZpp0cftuQk#*hwO0QLCYzvxj|1[i   [L0bm|uC_               
                                                 "_[1(/tff|)/vULmpqLufnLhW8MhpwwmZO0LCYznf|)[-i^t0mkY|Uu^                
                                                I?}1|/ff|)/vJQmpwCnjXpW%8MobbbbpmmZ0CXvxj/|){[_!XkwjxJ]                  
                                               !?})|/t|1/cJQwpmJxfXk8%&W#ahhhbdpqZLYvnxrjft|(1}<]CtXx`                   
                                              I?[)|/|{|vULmpmUr/cd8%WMM*oahkkbpZLXcvuunxrjft|){]l/U+                     
                                             '_])|(}(vULmdwJr|uq&%W##M*oahhkpOCXzzcvuunnxrjt|){?>+.                      
                                             i?1)[1uUJZpwCx|rZW8M**MM#*oakqQJYXzzcccvvuuxrjt/({?~                        
                                             -[?[xYU0pqLn|tL*8Moa*MM#*ohqQJYXXzzzzzzcvuunxjf/)}->                        
                                            ^+_tXYLqp0v||zb&Mah*#MMM*hqQJYYXXXXXXXXzcvcvurf/({]+!                        
                                            '1zXUmpZX/1r0*&oho###**aqQJYYXXXXXXXXXzzXzvnjf/(1[-<"                        
                                           ;uXc0pmJj{(Xq#*kkaahhkkqQUYXXXXXXXYXXXXYXcuxjft|)}?+!                         
                                          |YrYpqQu{[fJpabqdddpdbqQUXXXzXXXXYYXXYUYcunxjf/({[-<!                          
                                        <XujOdZY(-[jJmpmZmwqqqwQYXXzzzXXXXXXXYUYzunxrf/({[?~il'                          
                                       fJtzdq0x_<[tvC0LL0OZOZ0YzzzzzzzzXXXXXUYcuunxj/|1}?~iI,                            
                                     <Uv/ObZC?`!-1jvXXYJCLLQJcvvvvvvczzzzzXXcunnrjt(1}?~>l;"                             
                                    |L/nbq0X!   <}|jruvzXYUvnnnnnuuuvvvvzzcnxxrjt(1}?~>!I:'                              
                                  ;cU1JhZ0v,     ;?1(tjnuvrfjjrrxxnnnnuvuxrjjf/(1{?~>!l:`                                
                                 -Cv{mkO0v"        !]1(/ft|//tfjjjjjjrxrfft/|({[?~i!I,'                                  
                                (Qj)bdOQz:           I_}1}1)(||/t///tt/||()1}]?+iI:`                                     
                              ^j0/(apZLJ+              ';!<~-]{111111{{{}]]?+<i:'                                        
                             Ir0|)opZ0Cx'.              :]f/|{<+-____~~<iI:^.                                            
                            !xLj?opmZCJ/  .         ">1uLqdqCurx?'                                                       
                           !xYX!bbqmOCYz_^.   '^I~{jX0pdmJurrt_                                                          
                          :ruZlv*pwZZLUYYnt|/fxcUQmpdmJurrf[,                                                            
                          trLn"bddpmZZ0LCCLLQOmpdpOYnjjj{I                                                               
                         }jnO{^akppqwmmmmwpdbdmCvjfjf{l                                                                  
                        "/fnQx {hoaaaahkdwQYnf/fjt[I                                                                     
                        ~|frz0t,I}trxrj/(((tjj(_"                                                                        
                        >|)tjnYYx(11)|tjrj|?I                                                                            
                         [)(|||/jrrjt([<,                                                                                
                          ^i~__+<!:`                                                                                     
                      '';
                      sections = [
                        {
                          section = "header";
                        }
                      ];
                    };

                    toggleterm = {
                      enable = true;
                      settings = {
                        direction = "float";
                        float_opts.border = "curved";
                        open_mapping = "[[<C-\\>]]";
                      };
                    };
                  };

                  wondervim = {
                    enable = true;
                    debugging = true;
                    enableDarkmanIntegration = true;

                    keymaps = [
                      {
                        key = "<C-=>";
                        lua = "vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1";
                      }
                      {
                        key = "<C-->";
                        lua = "vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1";
                      }
                    ];

                    plugins.incline = {
                      package = pkgs.vimPlugins.incline-nvim;
                      settings.render.__raw = ''
                        (function()
                          local helpers = require("incline.helpers")
                          local devicons = require("nvim-web-devicons")

                          return function(props)
                            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
                            if filename == "" then
                              return {}
                            end

                            local ft_icon, ft_color = devicons.get_icon_color(filename)
                            local modified = vim.bo[props.buf].modified
                            return {
                              ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
                              " ",
                              { filename, gui = modified and "bold,italic" or "bold" },
                              " "
                            }
                          end
                        end)()
                      '';
                    };
                  };
                };
            }
          );

          font = {
            size = 12;
            edging = "subpixelantialias";
            normal = "Monaspace Neon";

            italic = {
              family = "Monaspace Radon";
              style = "Regular";
            };

            bold_italic = {
              family = "Monaspace Radon";
              style = "Bold";
            };

            features =
              let
                features = [
                  "+calt"
                  "+liga"
                  "+ss01"
                  "+ss02"
                  "+ss03"
                  "+ss04"
                  "+ss07"
                  "+ss08"
                  "+ss09"
                  "+ss10"
                  "cv01=2"
                  "+cv10"
                  "+cv11"
                  "+cv30"
                  "+cv31"
                ];
              in
              {
                "Monaspace Neon" = features;
                "Monaspace Radon" = features;
              };
          };
        };
      };

      home.packages = with pkgs; [
        monaspace
      ];
    };
}
