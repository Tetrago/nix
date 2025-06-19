{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkMerge
    ;
  inherit (lib.attrsets) mapAttrsToList optionalAttrs;
  inherit (lib.lists) optional;
in
{
  imports = [
    ./keymaps.nix
    ./plugins.nix
  ];

  options.wondervim = {
    enable = mkEnableOption "wondervim neovim configuration.";
    transparent = mkEnableOption "transparency support.";
    debugging = mkEnableOption "debug support.";
    enableDarkmanIntegration = mkEnableOption "darkman theme integration.";
  };

  config =
    let
      cfg = config.wondervim;
    in
    mkIf cfg.enable {
      withRuby = false;

      globals = {
        c_syntax_for_h = 1;
        mapleader = "\\";
      };

      opts = {
        number = true;
        relativenumber = true;

        expandtab = true;
        tabstop = 4;
        shiftwidth = 4;

        fillchars.eob = " ";
        mousemodel = "extend";

        sessionoptions = lib.strings.concatStringsSep "," [
          "blank"
          "buffers"
          "curdir"
          "folds"
          "help"
          "tabpages"
          "winsize"
          "winpos"
          "terminal"
          "localoptions"
        ];
      };

      diagnostic.settings = {
        virtual_lines = {
          only_current_line = true;
          highlight_whole_line = true;
        };
        virtual_text = false;
      };

      extraConfigLua = ''
        local signs = { Error = "󰅚 ", Warning = " ", Hint = "󰌶 ", Information = " " }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end
      '';

      extraConfigLuaPost = mkIf cfg.debugging ''
        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.before.attach.dapui_config = dapui.open
        dap.listeners.before.launch.dapui_config = dapui.open
        dap.listeners.before.event_terminated.dapui_config = dapui.close
        dap.listeners.before.event_exited.dapui_config = dapui.close
        require("dap.ext.vscode").load_launchjs()
      '';

      colorschemes.catppuccin = {
        enable = true;
        settings.background = {
          dark = "frappe";
          light = "latte";
        };
      };

      wondervim.keymaps =
        let
          binds =
            {
              "<Leader>X" = "Trouble diagnostics toggle";
              "<Leader>x" = "Trouble diagnostics toggle filter.buf=0";

              "go" = "sort";

              "gD" = "Glance definitions";
              "gR" = "Glance references";
              "gY" = "Glance type_definitions";
              "gM" = "Glance implementations";

              "<F6>" = "make";

              "<C-f>" = "Telescope current_buffer_fuzzy_find";
              "<C-k>" = "Telescope live_grep";
              "<C-i>" = "Telescope lsp_references";

              "<C-t>" = "Neotree toggle";
              "<C-S-t>" = "Neotree position=current";

              "<C-S-p>" = "Telescope session-lens";

              "-" = "Oil";
              "=" = "ClangdSwitchSourceHeader";

              "<C-g>" = "tabnew";
              "<C-x>" = "tabclose";

              "<Leader>s".plug = "leap-forward";
              "<Leader>S".plug = "leap-backward";
              "<Leader>gs".plug = "leap-from-window";
            }
            // optionalAttrs cfg.debugging {
              "<Leader>d".lua = "require('dapui').toggle()";

              "<F5>" = "DapContinue";
              "<F9>" = "DapToggleBreakpoint";
              "<F10>" = "DapStepOver";
              "<F11>" = "DapStepInto";
              "<F12>" = "DapStepOut";
            };
        in
        mapAttrsToList (
          key: v:
          if builtins.isString v then
            {
              inherit key;
              command = v;
            }
          else
            { inherit key; } // v
        ) binds;

      plugins = mkMerge [
        {
          autoclose.enable = true; # Maybe use blink?
          clangd-extensions.enable = true;
          colorizer.enable = true;
          dressing.enable = true; # Deprecated
          gitblame.enable = true;
          glance.enable = true;
          illuminate.enable = true;
          image.enable = true;
          indent-blankline.enable = true;
          lsp-lines.enable = true;
          lspkind.enable = true;
          neo-tree.enable = true;
          neogit.enable = true;
          neoscroll.enable = true;
          sleuth.enable = true;
          trouble.enable = true;
          vim-surround.enable = true;
          vimtex.enable = true;
          web-devicons.enable = true;

          auto-session = {
            enable = true;
            settings.cwd_change_handling = true;
          };

          blink-cmp = {
            enable = true;
            settings = {
              completion = {
                documentation = {
                  auto_show = true;
                  auto_show_delay_ms = 500;
                };

                ghost_text.enabled = true;

                list.selection = {
                  preselect = false;
                  auto_insert = true;
                };

                menu.draw.components.kind_icon = {
                  text.__raw = ''
                    function(ctx)
                      local icon = ctx.kind_icon
                      if vim.tbl_contains({ "Path" }, ctx.source_name) then
                        local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                        if dev_icon then
                          icon = dev-icon
                        end
                      else
                        icon = require("lspkind").symbolic(ctx.kind, {
                          mode = "symbol"
                        })
                      end

                      return icon .. ctx.icon_gap
                    end
                  '';

                  highlight.__raw = ''
                    function(ctx)
                      local hl = ctx.kind_hl
                      if vim.tbl_contains({ "Path" }, ctx.source_name) then
                        local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                        if dev_icon then
                          hl = dev_hl
                        end
                      end
                      return hl
                    end
                  '';
                };
              };

              keymap = {
                preset = "none";

                "<Tab>" = [
                  "select_next"
                  "fallback"
                ];

                "<S-Tab>" = [
                  "select_prev"
                  "fallback"
                ];

                "<C-Space>" = [ "show" ];
                "<CR>" = [ "accept" ];
                "<C-e>" = [ "cancel" ];
              };
            };
          };

          conform-nvim = {
            enable = true;

            settings = {
              formatters_by_ft = {
                bash = [ "shfmt" ];
                cmake = [ "gersemi" ];
                cpp = [ "clang-format" ];
                css = [ "prettierd" ];
                elixir = [ "mix" ];
                javascript = [ "prettierd" ];
                javascriptreact = [ "prettierd" ];
                json = [ "prettierd" ];
                html = [ "prettierd" ];
                nix = [ "nixfmt" ];
                python = [ "yapf" ];
                rust = [ "rustfmt" ];
                scss = [ "prettierd" ];
                sh = [ "shfmt" ];
                sql = [ "sqlfluff" ];
                systemverilog = [ "verible" ];
                typescript = [ "prettierd" ];
                typescriptreact = [ "prettierd" ];
                vhdl = [ "vsg" ];
                yaml = [ "prettierd" ];
                "_" = [ "trim_whitespace" ];
              };

              formatters = with pkgs; {
                shfmt.command = getExe shfmt;
                "clang-format".command = "${clang-tools}/bin/clang-format";
                gersemi.command = getExe gersemi;
                mix.command = "${elixir}/bin/mix";
                nixfmt.command = getExe nixfmt-rfc-style;
                prettierd.command = getExe prettierd;
                rustfmt.command = getExe (rustfmt.override { asNightly = true; });
                sqlfluff.command = getExe sqlfluff;
                yapf.command = getExe yapf;
                verible.command = "${verible}/bin/verible-verilog-format";
                vsg.command = getExe vsg;
              };

              format_on_save = {
                lsp_format = "fallback";
                timeout_ms = 500;
              };

              format_after_save = {
                lsp_format = "fallback";
              };
            };
          };

          gitsigns = {
            enable = true;
            settings = {
              signs.changedelete.text = "╏";
              signs_staged.changedelete.text = "╏";
            };
          };

          leap = {
            enable = true;
            addDefaultMappings = false;
          };

          lsp = {
            enable = true;
            inlayHints = true;
            servers = {
              clangd.enable = true;
              cmake.enable = true;
              docker_compose_language_service.enable = true;
              dockerls.enable = true;
              gopls.enable = true;
              html.enable = true;
              java_language_server.enable = true;
              jsonls.enable = true;
              lua_ls.enable = true;
              nil_ls.enable = true;
              svls.enable = true;
              taplo.enable = true;
              vhdl_ls.enable = true;
              vtsls.enable = true;
              zls.enable = true;

              rust_analyzer = {
                enable = true;
                installCargo = false;
                installRustc = false;
                settings = {
                  cargo.loadOutDirsFromCheck = true;
                  check.command = "clippy";
                };
              };
            };
          };

          lsp-status = {
            enable = true;
            settings.status_symbol = " ";
          };

          lualine = {
            enable = true;

            luaConfig.pre = ''
              local trouble_statusline = require("trouble").statusline({
                mode = "lsp_document_symbols",
                groups = {},
                title = false,
                filter = { range = true },
                format = "{kind_icon}{symbol.name:Normal}",
                hl_group = "lualine_c_normal"
              })
            '';

            settings = {
              options = {
                component_separators = {
                  left = "";
                  right = "";
                };

                section_separators = {
                  left = "";
                  right = "";
                };

                theme.__raw = ''
                  (function()
                    local theme = require("lualine.themes.auto")

                    theme.normal.c.bg = nil
                    theme.normal.c.fg = theme.normal.a.fg
                    theme.inactive.c.bg = nil

                    return theme
                  end)()
                '';
              };

              extensions = [
                "neo-tree"
                "nvim-dap-ui"
                "oil"
                "trouble"
              ];

              sections = {
                lualine_a = [
                  {
                    __unkeyed-1 = "mode";
                    separator.left = "";

                    padding = {
                      left = 0;
                      right = 2;
                    };
                  }
                ];

                lualine_b = [
                  "filename"
                  "branch"
                ];
                lualine_c = [
                  {
                    __unkeyed-1.__raw = "trouble_statusline.get";
                    cond.__raw = "trouble_statusline.has";
                  }
                  "%="
                ];

                lualine_x = [
                  {
                    __unkeyed-1.__raw = ''function() return require("lsp-status").status() end'';
                    cond.__raw = ''function() return require("lsp-status").status() ~= "" end'';
                  }
                ];
                lualine_y = [ "filetype" ];

                lualine_z = [
                  {
                    __unkeyed-1 = "location";
                    separator.right = "";

                    padding = {
                      left = 2;
                      right = 0;
                    };
                  }
                ];
              };

              inactive_sections = {
                lualine_a = [ "" ];

                lualine_b = [
                  {
                    __unkeyed-1 = "filename";

                    separator = {
                      left = "";
                      right = "";
                    };
                  }
                ];

                lualine_c = [ "" ];
                lualine_x = [ "" ];
                lualine_y = [ "" ];
                lualine_z = [ "" ];
              };
            };
          };

          noice = {
            enable = true;
            settings = {
              presets = {
                bottom_search = true;
                command_palette = true;
                long_message_to_split = true;
              };

              lsp.override = {
                "vim.lsp.util.convert_input_to_markdown_lines" = true;
                "vim.lsp.util.stylize_markdown" = true;
              };
            };
          };

          notify = {
            enable = true;

            luaConfig.post = ''
              vim.api.nvim_create_autocmd({ "WinEnter", "BufLeave" }, {
                pattern = "*",
                callback = function()
                  while vim.api.nvim_buf_get_option(0, "filetype") == "notify" do
                    vim.cmd("wincmd w")
                  end
                end
              })
            '';

            settings.stages = "static";
          };

          oil = {
            enable = true;
            settings.win_options.signcolumn = "yes:2"; # For oil-git-status
          };

          oil-git-status = {
            enable = true;
            settings.symbols =
              let
                symbols = {
                  "!" = "";
                  "?" = "";
                  "A" = "";
                  "C" = "";
                  "D" = "";
                  "M" = "";
                  "R" = "";
                  "T" = "󰑖";
                  "U" = "";
                  " " = " ";
                };
              in
              {
                index = symbols;
                working_tree = symbols;
              };
          };

          render-markdown = {
            enable = true;
            settings.completions.lsp.enabled = true;
          };

          telescope = {
            enable = true;

            extensions = {
              fzf-native.enable = true;
              media-files.enable = true;
            };

            keymaps = {
              "<C-p>".action = "find_files";
            };
          };

          transparent = mkIf cfg.transparent {
            enable = true;
            settings.groups = [
              "Normal"
              "NormalNC"
              "EndOfBuffer"
              "MsgArea"
              "FloatBorder"
              "VertSplit"
              "SignColumn"
              "StatusLine"
              "StatusLineNC"
              "WinSeparator"
              "CursorLine"
              "CursorLineNr"
              "LineNr"
              "FoldColumn"
              "Pmenu"
              "PmenuSbar"
              "PmenuThumb"

              "NeoTreeNormal"
              "NeoTreeNormalNC"
              "NeoTreeVertSplit"
              "NeoTreeWinSeparator"
              "NeoTreeEndOfBuffer"

              "TelescopeNormal"
              "TelescopeBorder"
            ];
          };

          treesitter = {
            enable = true;
            settings = {
              ensure_installed = [
                "nix"
                "bash"
                "lua"
                "python"
                "json"
                "javascript"
                "c"
                "cpp"
                "cmake"
                "rust"
                "java"
                "make"
                "markdown"
                "markdown_inline"
                "nix"
                "haskell"
                "c_sharp"
                "regex"
                "toml"
                "dockerfile"
                "rust"
                "typescript"
                "zig"
                "elixir"
              ];
            };
          };

          treesitter-refactor = {
            enable = true;
            highlightDefinitions.enable = true;
            smartRename = {
              enable = true;
              keymaps.smartRename = "grr";
            };
          };
        }
        (mkIf cfg.debugging {
          dap-ui.enable = true;
          dap-virtual-text.enable = true;

          dap = {
            enable = true;

            adapters.executables =
              let
                gdb = {
                  command = getExe pkgs.gdb;
                  args = [
                    "-i"
                    "dap"
                  ];
                };
              in
              {
                c = gdb;
                cpp = gdb;
                zig = gdb;
              };

            signs = {
              dapBreakpoint.text = "•";
              dapStopped = {
                text = "•";
                texthl = "DiagnosticError";
              };
            };
          };
        })
      ];

      wondervim.plugins.darkman = mkIf cfg.enableDarkmanIntegration {
        package = pkgs.darkman-nvim;
        settings.change_background = true;
      };

      extraPlugins =
        optional cfg.transparent pkgs.bg-nvim
        ++ (with pkgs.vimPlugins; [
          vim-indent-object
          vim-textobj-entire
        ]);

      dependencies = {
        fzf.enable = true;
        ripgrep.enable = true;
      };

      extraPackages = with pkgs; [
        fd
      ];
    };
}
