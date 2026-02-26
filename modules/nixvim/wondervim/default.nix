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
    mkOption
    types
    ;
  inherit (lib.attrsets)
    filterAttrs
    genAttrs
    mapAttrs'
    mapAttrsToList
    optionalAttrs
    ;
  inherit (lib.lists) flatten optional;
  inherit (lib.strings) concatStrings stringToCharacters toLower;

  localPkgs = import ./packages pkgs;
in
{
  imports = [
    ./keymaps.nix
    ./plugins.nix
    ./treats.nix
  ];

  options.wondervim = {
    enable = mkEnableOption "wondervim neovim configuration.";
    transparent = mkEnableOption "transparency support.";
    enableDebugging = mkEnableOption "debug support.";
    enableThemeIntegration = mkEnableOption "automatic theme switching integration.";

    cheatsheets = mkOption {
      type = with types; attrsOf path;
      default = { };
    };

    sessionHooks =
      genAttrs
        [
          "preSave"
          "saveExtra"
          "postSave"
          "preRestore"
          "postRestore"
          "preDelete"
          "postDelete"
          "noRestore"
          "preCwdChanged"
          "postCwdChanged"
        ]
        (
          _:
          mkOption {
            type = with types; nullOr (coercedTo str (x: [ x ]) (listOf str));
            default = null;
          }
        );
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
        cursorline = true;

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

        foldlevel = 99;
        foldlevelstart = 99;
      };

      colorschemes.vscode.enable = true;

      diagnostic.settings = {
        severity_sort = true;

        signs = {
          text =
            mapAttrs'
              (n: v: {
                name = "__rawKey__vim.diagnostic.severity.${n}";
                value = v;
              })
              {
                ERROR = "";
                WARN = "";
                INFO = "";
                HINT = "";
              };

          numhl =
            mapAttrs'
              (n: v: {
                name = "__rawKey__vim.diagnostic.severity.${n}";
                value = v;
              })
              {
                ERROR = "DiagnosticSignError";
                WARN = "DiagnosticSignWarn";
                INFO = "DiagnosticSignInfo";
                HINT = "DiagnosticSignHint";
              };
        };

        virtual_lines = {
          current_line = true;
          highlight_whole_line = true;
        };

        virtual_text = false;
      };

      extraFiles = mkMerge (
        mapAttrsToList (n: v: { "cheatsheets/cheatsheet-${n}.txt".source = v; }) cfg.cheatsheets
      );

      wondervim = {
        cheatsheets.wondervim = ./cheatsheet.txt;

        keymaps =
          let
            binds = {
              "<M-g>".lua = "Snacks.lazygit.open()";
              "<M-t>" = "TodoTelescope";

              "<C-s>" = "TSJSplit";
              "<C-j>" = "TSJJoin";

              "gD" = "Glance definitions";
              "gR" = "Glance references";
              "gY" = "Glance type_definitions";
              "gM" = "Glance implementations";
              "gd".lua = "vim.lsp.buf.definition()";

              "gxx".lua = "vim.diagnostic.setqflist({ scope = 'buffer' })";
              "gxe".lua =
                "vim.diagnostic.setqflist({ scope = 'buffer', severity = vim.diagnostic.severity.ERROR })";
              "gXx".lua = "vim.diagnostic.setqflist()";
              "gXe".lua = "vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })";

              "?" = "Cheatsheet";

              "<M-d>" = "cnext";
              "<M-a>" = "cprev";
              "<M-q>" = "ToggleQuickfix";

              "<C-f>" = "Telescope current_buffer_fuzzy_find";
              "<C-k>" = "Telescope live_grep";
              "<C-n>" = "Telescope notify";
              "<C-q>" = "Telescope quickfix";

              "<C-e>" = "Neotree position=float";

              "<C-S-p>" = "AutoSession search";

              "-" = "Oil";

              "<C-g>" = "tabnew";
              "<C-x>" = "tabclose";

              "gra".lua = "require('actions-preview').code_actions()";
              "gz".lua = "require('flash').treesitter()";
              "R".lua = "require('flash').jump()";
            }
            // optionalAttrs cfg.enableDebugging {
              "<M-f>".lua = "require('dapui').toggle()";

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
          ) binds
          ++ flatten (
            mapAttrsToList
              (n: v: [
                {
                  mode = [ "n" ];
                  key = "<S-${n}>";
                  action = "<Plug>GoNSM${v}";
                  options = { };
                }
                {
                  mode = [ "x" ];
                  key = "<S-${n}>";
                  action = "<Plug>GoVSM${v}";
                }
              ])
              {
                j = "Down";
                k = "Up";
                h = "Left";
                l = "Right";
              }
          )
          ++
            mapAttrsToList
              (n: v: {
                mode = [ "n" ];
                key = "<M-${n}>";
                lua = "require('smart-splits').resize_${v}()";
              })
              {
                j = "down";
                k = "up";
                h = "left";
                l = "right";
              }
          ++
            map
              (x: {
                mode = [ "x" ];
                key = x;
                action = "${x}gv";
              })
              [
                "<"
                ">"
              ]
          ++ [
            {
              mode = [ "x" ];
              key = "ac";
              lua = "require('align').align_to_char({ length = 1 })";
            }
            {
              mode = [ "x" ];
              key = "as";
              lua = "require('align').align_to_string({ preview = true })";
            }
            {
              mode = [ "x" ];
              key = "ar";
              lua = "require('align').align_to_string({ regex = true, preview = true })";
            }
          ];

        plugins = {
          auto-dark-mode.package = mkIf cfg.enableThemeIntegration localPkgs.auto-dark-mode-nvim;

          cheatsheet = {
            package = pkgs.vimPlugins.cheatsheet-nvim.overrideAttrs (
              final: prev: {
                postInstall = ''
                  ${prev.postInstall or ""}
                  echo "" > $out/cheatsheet.txt
                '';
              }
            );

            settings = {
              bundled_cheatsheets.enabled = mapAttrsToList (n: _: n) cfg.cheatsheets;
              bundled_plugin_cheatsheets = false;
              telescope_mappings = [ ];
            };
          };

          gomove = {
            package = pkgs.vimPlugins.nvim-gomove;
            settings = {
              map_defaults = false;
              reindent = false;
            };
          };
        };

        treats.bufferSkipPredicates = [
          ''
            function(win_id)
              local bufnr = vim.api.nvim_win_get_buf(win_id)
              local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

              return filetype == "notify"
            end
          ''
        ];
      };

      autoCmd = [
        {
          event = [ "User" ];
          pattern = "OilActionsPost";
          callback.__raw = ''
            function(event)
              if event.data.actions.type == "move" then
                Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
              end
            end
          '';
        }
      ];

      userCommands = {
        ToggleQuickfix = {
          desc = "Toggle quickfix window";
          command.__raw = ''
            function()
              for _, win in ipairs(vim.fn.getwininfo()) do
                if win.quickfix == 1 then
                  vim.cmd("cclose")
                  return
                end
              end

              vim.cmd("botright copen")
            end
          '';
        };

        W.command = "w";
        Wq.command = "wq";
      };

      plugins = mkMerge [
        {
          autoclose.enable = true;
          crates.enable = true;
          colorful-menu.enable = true;
          flash.enable = true;
          fugitive.enable = true;
          glance.enable = true;
          neoscroll.enable = true;
          nvim-bqf.enable = true;
          nvim-surround.enable = true;
          smart-splits.enable = true;
          sleuth.enable = true;
          tiny-devicons-auto-colors.enable = true;
          todo-comments.enable = true;
          vimtex.enable = true;
          web-devicons.enable = true;

          actions-preview = {
            enable = true;
            settings = {
              highlight_command = [
                (lib.nixvim.mkRaw "require('actions-preview.highlight').delta('${lib.getExe pkgs.delta} --side-by-side')")
              ];

              telescope = {
                layout_config = {
                  height = 0.9;
                  preview_cutoff = 20;
                  preview_height.__raw = ''
                    function(_, _, max_lines)
                      return max_lines - 15
                    end
                  '';
                  prompt_position = "top";
                  width = 0.8;
                };
                layout_strategy = "vertical";
                sorting_strategy = "ascending";
              };
            };
          };

          arrow = {
            enable = true;
            settings = {
              leader_key = "m";
              show_icons = true;
            };
          };

          auto-session = {
            enable = true;
            settings = {
              cwd_change_handling = true;
            }
            // mapAttrs' (n: v: {
              name =
                concatStrings (
                  map (
                    c:
                    let
                      c' = toLower c;
                    in
                    if c' != c then "_${c'}" else c
                  ) (stringToCharacters n)
                )
                + "_cmds";
              value = map (x: { __raw = x; }) v;
            }) (filterAttrs (_: v: v != null) cfg.sessionHooks);
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

                menu.draw = {
                  columns = [
                    {
                      __unkeyed-1 = "kind_icon";
                    }
                    {
                      __unkeyed-1 = "label";
                      gap = 1;
                    }
                  ];
                  components = {
                    kind_icon = {
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

                    label = {
                      text.__raw = ''
                        function(ctx)
                          return require("colorful-menu").blink_components_text(ctx)
                        end
                      '';

                      highlight.__raw = ''
                        function(ctx)
                          return require("colorful-menu").blink_components_highlight(ctx)
                        end
                      '';
                    };
                  };
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

                "<C-Space>" = [
                  "show"
                  "fallback"
                ];

                "<CR>" = [
                  "accept"
                  "fallback"
                ];

                "<C-e>" = [
                  "cancel"
                  "fallback"
                ];
              };

              signature.enabled = true;
            };
          };

          colorizer = {
            enable = true;
            settings.user_default_options.names = false;
          };

          conform-nvim = {
            enable = true;

            settings = {
              formatters_by_ft = {
                "_" = [ "trim_whitespace" ];
                bash = [ "shfmt" ];
                c = [ "clang-format" ];
                cmake = [ "gersemi" ];
                cpp = [ "clang-format" ];
                css = [ "prettierd" ];
                elixir = [ "mix" ];
                gleam = [ "gleam" ];
                html = [ "prettierd" ];
                java = [ "google-java-format" ];
                javascript = [ "prettierd" ];
                javascriptreact = [ "prettierd" ];
                json = [ "prettierd" ];
                nix = [ "nixfmt" ];
                python = [ "yapf" ];
                rust = [ "rustfmt" ];
                scss = [ "prettierd" ];
                sh = [ "shfmt" ];
                sql = [ "sqlfluff" ];
                systemverilog = [ "verible" ];
                toml = [ "taplo" ];
                typescript = [ "prettierd" ];
                typescriptreact = [ "prettierd" ];
                vhdl = [ "vsg" ];
                wgsl = [ "wgslfmt" ];
                yaml = [ "prettierd" ];
              };

              formatters = with pkgs; {
                "clang-format".command = "${clang-tools}/bin/clang-format";
                gersemi.command = getExe gersemi;
                gleam.command = getExe gleam;
                google-java-format.command = getExe google-java-format;
                mix.command = "${elixir}/bin/mix";
                nixfmt.command = getExe nixfmt;
                prettierd.command = getExe prettierd;
                rustfmt.command = getExe (rustfmt.override { asNightly = true; });
                shfmt.command = getExe shfmt;
                sqlfluff.command = getExe sqlfluff;
                taplo.command = getExe taplo;
                verible.command = "${verible}/bin/verible-verilog-format";
                vsg.command = getExe vsg;
                wgslfmt = {
                  command = "wgslfmt";
                  stdin = true;
                };
                yapf.command = getExe yapf;
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

          lsp = {
            enable = true;
            inlayHints = true;
            servers = {
              clangd.enable = true;
              cmake.enable = true;
              docker_compose_language_service.enable = true;
              dockerls.enable = true;
              gleam.enable = true;
              gopls.enable = true;
              html.enable = true;
              jdtls.enable = true;
              jsonls.enable = true;
              lua_ls.enable = true;
              nil_ls.enable = true;
              svls.enable = true;
              taplo.enable = true;
              wgsl_analyzer.enable = true;
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

          lspkind = {
            enable = true;
            cmp.enable = false;
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

                    for _, mode in pairs(theme) do
                      if mode.c == nil then
                        mode.c = {}
                      end

                      mode.c.bg = nil
                    end

                    return theme
                  end)()
                '';
              };

              extensions = [
                "fugitive"
                "neo-tree"
                "nvim-dap-ui"
                "oil"
                "quickfix"
                "toggleterm"
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
                    __unkeyed-1 = "diagnostics";
                    sources = [ "nvim_workspace_diagnostic" ];
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

          neo-tree = {
            enable = true;
            settings = {
              hide_root_node = true;
              retain_hidden_root_indent = true;
              nesting_rules.__raw = "require('neotree-file-nesting-config').nesting_rules";

              event_handlers = {
                file_moved = "function(data) Snacks.rename.on_rename_file(data.source, data.destination) end";
                file_renamed = "function(data) Snacks.rename.on_rename_file(data.source, data.destination) end";
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

              lsp = {
                override = {
                  "vim.lsp.util.convert_input_to_markdown_lines" = true;
                  "vim.lsp.util.stylize_markdown" = true;
                };

                hover.enabled = false;
                progress.enabled = false;
                signature.enabled = false;
              };
            };
          };

          notify = {
            enable = true;
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

          origami = {
            enable = true;
            settings = {
              autoFold.enabled = false;
              foldtext.lineCount.template = "󰘖%d"; # FIX: I don't know why this doesn't work
              foldKeymaps.setup = false;
            };
          };

          render-markdown = {
            enable = true;
            settings.completions.lsp.enabled = true;
          };

          snacks = {
            enable = true;
            settings = {
              bigfile.enabled = true;
              input.enabled = true;
              lazygit.enabled = true;
              quickfile.enabled = true;
              words.enabled = true;

              indent = {
                enabled = true;
                animate.enabled = false;
                indent.char = "▏";

                scope = {
                  enabled = true;
                  char = "▏";
                };

                chunk = {
                  enabled = true;
                  char = {
                    arrow = "─";
                    corner_top = "╭";
                    corner_bottom = "╰";
                  };
                };
              };
            };
          };

          telescope = {
            enable = true;

            extensions = {
              fzf-native.enable = true;
              ui-select.enable = true;
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
            grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
              bash
              c
              c_sharp
              cmake
              cpp
              dockerfile
              elixir
              gleam
              haskell
              java
              javascript
              json
              lua
              make
              markdown
              markdown_inline
              nix
              nix
              python
              regex
              rust
              rust
              toml
              typescript
              wgsl
              zig
            ];
            settings = {
              highlight.enable = true;
            };
          };

          treesj = {
            enable = true;
            settings.use_default_keymaps = false;
          };
        }
        (mkIf cfg.enableDebugging {
          dap-ui.enable = true;
          dap-virtual-text.enable = true;

          dap = {
            enable = true;

            adapters.executables = {
              lldb.command = "${pkgs.lldb}/bin/lldb-dap";
            }
            //
              genAttrs
                [
                  "c"
                  "cpp"
                  "zig"
                ]
                (_: {
                  command = getExe pkgs.gdb;
                  args = [
                    "-i"
                    "dap"
                  ];
                });

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

      extraPlugins =
        optional cfg.transparent localPkgs.bg-nvim
        ++ [ localPkgs.neotree-file-nesting-config ]
        ++ (with pkgs.vimPlugins; [
          align-nvim
          vim-expand-region
          vim-indent-object
          vim-textobj-comment
          vim-textobj-entire
        ]);

      dependencies = {
        fzf.enable = true;
        gcc.enable = true;
        lazygit.enable = true;
        ripgrep.enable = true;
      };

      extraPackages = with pkgs; [
        fd
        texliveFull
      ];
    };
}
