{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) getExe mkEnableOption mkIf;
  inherit (lib.attrsets) mapAttrsToList;
in
{
  options.wondervim = {
    enable = mkEnableOption "wondervim neovim configuration.";
    transparent = mkEnableOption "transparency support.";
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

      extraConfigLua = ''
        vim.api.nvim_create_autocmd({ "WinEnter", "BufLeave" }, {
          pattern = "*",
          callback = function()
            while vim.api.nvim_buf_get_option(0, "filetype") == "notify" do
              vim.cmd("wincmd w")
            end
          end
        })

        local signs = { Error = "󰅚 ", Warning = " ", Hint = "󰌶 ", Information = " " }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end
      '';

      extraConfigLuaPost = ''
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

      globals.mapleader = "\\";

      keymaps =
        let
          mkCommand = key: command: {
            mode = "n";
            key = "<Leader>${key}";
            options.silent = true;
            action = "<Cmd>${command}<CR>";
          };
          mkAction = key: command: {
            mode = "n";
            inherit key;
            options.silent = true;
            action = "<Cmd>${command}<CR>";
          };
        in
        [
          (mkCommand "d" "lua require('dapui').toggle()")

          (mkCommand "X" "Trouble diagnostics toggle")
          (mkCommand "x" "Trouble diagnostics toggle filter.buf=0")

          (mkAction "<F6>" "make")

          (mkAction "<F5>" "DapContinue")
          (mkAction "<F9>" "DapToggleBreakpoint")
          (mkAction "<F10>" "DapStepOver")
          (mkAction "<F11>" "DapStepInto")
          (mkAction "<F12>" "DapStepOut")

          (mkAction "<C-f>" "Telescope current_buffer_fuzzy_find")
          (mkAction "<C-k>" "Telescope live_grep")
          (mkAction "<C-i>" "Telescope lsp_references")

          (mkAction "<C-t>" "Neotree toggle")
          (mkAction "<C-S-t>" "Neotree position=current")

          (mkAction "-" "Oil")
          (mkAction "=" "ClangdSwitchSourceHeader")

          (mkAction "<C-g>" "tabnew")
          (mkAction "<C-x>" "tabclose")
        ]
        ++ [
          {
            mode = [
              "n"
              "i"
            ];
            options.silent = true;
            key = "<F1>";
            action = "<Nop>";
          }
        ]
        ++ (
          mapAttrsToList
            (key: action: {
              mode = [
                "n"
                "x"
                "o"
              ];

              options.silent = true;
              inherit action;
              key = "\\${key}";
            })
            {
              s = "<Plug>(leap-forward)";
              S = "<Plug>(leap-backward)";
              gs = "<Plug>(leap-from-window)";
            }
          ++ [
            {
              mode = [
                "n"
                "i"
              ];

              options.silent = true;
              key = "<F1>";
              action = "<Nop>";
            }
          ]
        );

      plugins = {
        autoclose.enable = true;
        auto-session.enable = true;
        clangd-extensions.enable = true;
        dressing.enable = true;
        fugitive.enable = true;
        gitsigns.enable = true;
        illuminate.enable = true;
        image.enable = true;
        indent-blankline.enable = true;
        lspkind.enable = true;
        neoscroll.enable = true;
        neo-tree.enable = true;
        colorizer.enable = true;
        oil.enable = true;
        sleuth.enable = true;
        trouble.enable = true;
        vimtex.enable = true;
        vim-surround.enable = true;
        web-devicons.enable = true;

        cmp = {
          enable = true;
          settings = {
            mapping = {
              "<C-space>" = "cmp.mapping.complete()";
              "<C-e>" = "cmp.mapping.close()";
              "<C-a>" = "cmp.mapping.abort()";
              "<CR>" = "cmp.mapping.confirm({ select = false })";
              "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            };

            sources = [
              { name = "nvim_lsp_signature_help"; }
              { name = "nvim_lsp"; }
              { name = "treesitter"; }
              { name = "buffer"; }
              { name = "dap"; }
              { name = "path"; }
            ];

            window = {
              completion.border = "rounded";
              documentation.border = "rounded";
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

        dap-ui.enable = true;
        dap-virtual-text.enable = true;

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
            elixirls.enable = true;
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

            hls = {
              enable = true;
              installGhc = true;
            };

            rust_analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
              settings.cargo.loadOutDirsFromCheck = true;
            };
          };
        };

        lualine = {
          enable = true;

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
                    theme.inactive.c.bg = nil

                    return theme
                  end
                )()
              '';
            };

            extensions = [
              "fugitive"
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
                "diagnostics"
                "%="
              ];

              lualine_x = [ "fileformat" ];
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
              "cmp.entry.get_documentation" = true;
              "vim.lsp.util.convert_input_to_markdown_lines" = true;
              "vim.lsp.util.stylize_markdown" = true;
            };
          };
        };

        notify = {
          enable = true;
          settings.stages = "static";
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

            highlight = {
              enable = true;
              additional_vim_regex_highlighting = true;
            };
          };
        };
      };

      extraPlugins = [
        (mkIf cfg.transparent pkgs.bg-nvim)
        (mkIf cfg.enableDarkmanIntegration {
          plugin = pkgs.darkman-nvim;
          config = "lua require('darkman').setup({ change_background = true })";
        })
      ];

      extraPackages = with pkgs; [
        fd
        ripgrep
      ];
    };
}
