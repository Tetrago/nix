{
  config,
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}:

let
  inherit (builtins)
    foldl'
    genList
    readFile
    stringLength
    ;
  inherit (lib) mkEnableOption mkForce mkIf;
  inherit (lib.strings)
    concatLines
    concatStrings
    concatStringsSep
    splitString
    ;

  stubNames = [
    "default.nix"
    "mod.rs"
  ];

  header =
    let
      text = readFile ./header.txt;
      lines = splitString "\n" text;

      maxLength = foldl' (
        acc: line:
        let
          length = stringLength line;
        in
        if length > acc then length else acc
      ) 0 lines;

      padLine =
        line:
        let
          length = maxLength - stringLength line;
          padding = concatStrings (genList (_: " ") length);
        in
        line + padding;
    in
    concatLines (map padLine lines);
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
                  imports = [ outputs.nixvimModules.wondervim ];

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
                          vim.keymap.set('t', '<C-v>', [[<C-\><C-n>]], opts)
                        end
                      '';
                    }
                  ];

                  plugins = {
                    auto-session.settings.suppressed_dirs = [ config.home.homeDirectory ];
                    direnv.enable = true;
                    neoscroll.enable = mkForce false;

                    snacks.settings.dashboard = {
                      enabled = true;
                      preset.header = header;
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
                    enableDebugging = true;
                    enableThemeIntegration = true;

                    cheatsheets.neovide = ./cheatsheet.txt;

                    keymaps = [
                      {
                        key = "<C-=>";
                        lua = "vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1";
                      }
                      {
                        key = "<C-->";
                        lua = "vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1";
                      }
                      {
                        key = "<C-w>m";
                        command = "WinShift";
                      }
                      {
                        key = "<C-w>x";
                        command = "WinShift swap";
                      }
                    ];

                    plugins = {
                      incline = {
                        package = pkgs.vimPlugins.incline-nvim;
                        settings.render.__raw = ''
                          (function()
                            local helpers = require("incline.helpers")
                            local devicons = require("nvim-web-devicons")

                            return function(props)
                              local path = vim.api.nvim_buf_get_name(props.buf)
                              if path == "" then return {} end

                              local filename = vim.fn.fnamemodify(path, ":t")
                              
                              local name
                              if ${concatStringsSep " or " (map (x: ''filename == "${x}"'') stubNames)} then
                                name = vim.fn.fnamemodify(path, ":h:t")
                              else
                                name = filename
                              end

                              local ft_icon, ft_color = devicons.get_icon_color(filename)
                              local modified = vim.bo[props.buf].modified
                              return {
                                ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
                                " ",
                                { name, gui = modified and "bold,italic" or "bold" },
                                " "
                              }
                            end
                          end)()
                        '';
                      };

                      winshift = {
                        package = pkgs.vimPlugins.winshift-nvim;
                        settings.window_picker.__raw = ''
                          function()
                            return require("winshift.lib").pick_window({
                              picker_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                              filter_rules = {
                                cur_win = true,
                                floats = true,
                                filetype = { },
                                buftype = {},
                                bufname = {},
                              },
                              filter_func = nil,
                            })
                          end
                        '';
                      };
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
