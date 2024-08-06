{ inputs, lib, pkgs, ... }:

let
  inherit (lib) mapAttrsToList;
  inherit (lib.strings) concatStringsSep;
in {
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;
    withRuby = false;

    opts = {
      number = true;
      relativenumber = true;

      expandtab = true;
      tabstop = 4;
      shiftwidth = 4;

      fillchars.eob = " ";
      mousemodel = "extend";

      sessionoptions = concatStringsSep "," [
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
          if vim.api.nvim_buf_get_option(0, "filetype") == "notify" then
            vim.cmd("wincmd w")
          end
        end
      })

      local darkMode = true
      vim.keymap.set("n", "<C-g>", function()
        if darkMode then
          vim.cmd("colorscheme dayfox")
        else
          vim.cmd("colorscheme carbonfox")
        end

        darkMode = not darkMode
      end, { silent = true, noremap = true })

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

    colorschemes.nightfox = {
      enable = true;
      flavor = "carbonfox";
      settings.options = {
        styles = {
          comments = "italic";
          keyword = "bold";
          types = "italic,bold";
        };
      };
    };

    globals.mapleader = " ";

    keymaps = let
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
    in [
      (mkCommand "d" "lua require('dapui').toggle()")
      (mkCommand "o" "OverseerToggle")
      (mkCommand "r" "OverseerRun")

      (mkCommand "x" "Trouble diagnostics toggle")
      (mkCommand "X" "Trouble diagnostics toggle filter.buf=0")

      (mkAction "<F6>" "make")

      (mkAction "<F5>" "DapContinue")
      (mkAction "<F9>" "DapToggleBreakpoint")
      (mkAction "<F10>" "DapStepOver")
      (mkAction "<F11>" "DapStepInto")
      (mkAction "<F12>" "DapStepOut")

      (mkAction "<C-f>" "Telescope current_buffer_fuzzy_find")
      (mkAction "<C-k>" "Telescope live_grep")
      (mkAction "<C-i>" "Telescope lsp_references")

      (mkAction "<C-t>" "Neotree position=current")

      (mkAction "-" "Oil")
      (mkAction "=" "ClangdSwitchSourceHeader")
    ] ++ (mapAttrsToList (key: action: {
      mode = [ "n" "x" "o" ];
      options.silent = true;
      inherit action key;
    }) {
      s = "<Plug>(leap-forward)";
      S = "<Plug>(leap-backward)";
      gs = "<Plug>(leap-from-window)";
    } ++ [{
      mode = [ "n" "i" ];
      options.silent = true;
      key = "<F1>";
      action = "<Nop>";
    }]);

    plugins = {
      autoclose.enable = true;
      barbecue.enable = true;
      clangd-extensions.enable = true;
      dressing.enable = true;
      fugitive.enable = true;
      gitsigns.enable = true;
      illuminate.enable = true;
      indent-blankline.enable = true;
      lspkind.enable = true;
      neoscroll.enable = true;
      neo-tree.enable = true;
      nix.enable = true;
      nvim-colorizer.enable = true;
      oil.enable = true;
      surround.enable = true;
      trouble.enable = true;

      auto-session = {
        enable = true;
        extraOptions = {
          pre_save_cmds = [
            { __raw = ''require("dapui").close''; }
            {
              __raw = ''
                function()
                  local overseer = require("overseer")

                  overseer.save_task_bundle(
                    vim.fn.getcwd(0):gsub("[^A-Za-z0-9]", "_"),
                    nil,
                    { on_conflict = "overwrite" }
                  )

                  overseer.close()
                end
              '';
            }
          ];

          pre_restore_cmds = [{
            __raw = ''
              function()
                for _, task in ipairs(require("overseer").list_tasks({})) do
                  task:dispose(true)
                end
              end
            '';
          }];

          post_restore_cmds = [{
            __raw = ''
              function()
                require("overseer").load_task_bundle(
                  vim.fn.getcwd(0):gsub("[^A-Za-z0-9]", "_"),
                  { ignore_missing = true }
                )
              end
            '';
          }];
        };
      };

      cmp = {
        enable = true;
        settings = {
          mapping = {
            "<C-space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.close()";
            "<C-a>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = false })";
            "<S-Tab>" =
              "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
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

        formattersByFt = {
          cpp = [ "clang-format" ];
          cmake = [ "cmake_format" ];
          nix = [ "nixfmt" ];
          "_" = [ "trim_whitespace" ];
        };

        formatters = {
          nixfmt.command = "${pkgs.nixfmt}/bin/nixfmt";
          "clang-format".command = "${pkgs.clang-tools}/bin/clang-format";
          "cmake_format".command = "${pkgs.cmake-format}/bin/cmake-format";
        };

        formatOnSave = {
          lspFallback = true;
          timeoutMs = 500;
        };

        formatAfterSave = { lspFallback = true; };
      };

      dap = {
        enable = true;

        adapters.executables = let
          gdb = {
            command = "${pkgs.gdb}/bin/gdb";
            args = [ "-i" "dap" ];
          };
        in {
          c = gdb;
          cpp = gdb;
          zig = gdb;
        };

        extensions = {
          dap-ui.enable = true;
          dap-virtual-text.enable = true;
        };

        signs = {
          dapBreakpoint.text = "•";
          dapStopped = {
            text = "•";
            texthl = "DiagnosticError";
          };
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
          docker-compose-language-service.enable = true;
          dockerls.enable = true;
          gopls.enable = true;
          html.enable = true;
          hls.enable = true;
          java-language-server.enable = true;
          jsonls.enable = true;
          lua-ls.enable = true;
          nil_ls.enable = true;
          ocamllsp.enable = true;
          taplo.enable = true;
          vhdl-ls.enable = true;

          zls = {
            enable = true;
            onAttach.function = "vim.g.zig_fmt_autosave = 0";
          };

          rust-analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
        };
      };

      lualine = {
        enable = true;

        theme.__raw = ''
          (function()
              local theme = require("lualine.themes.auto")

              theme.normal.c.bg = nil
              theme.inactive.c.bg = nil

              return theme
            end
          )()
        '';

        componentSeparators = {
          left = "";
          right = "";
        };

        extensions =
          [ "fugitive" "neo-tree" "nvim-dap-ui" "oil" "trouble" "overseer" ];

        sectionSeparators = {
          left = "";
          right = "";
        };

        sections = {
          lualine_a = [{
            name = "mode";
            separator.left = "";

            padding = {
              left = 0;
              right = 2;
            };
          }];

          lualine_b = [ "filename" "branch" ];
          lualine_c = [ "diagnostics" "%=" ];

          lualine_x = [ "fileformat" ];
          lualine_y = [ "filetype" ];

          lualine_z = [{
            name = "location";
            separator.right = "";

            padding = {
              left = 2;
              right = 0;
            };
          }];
        };

        inactiveSections = {
          lualine_a = [ "" ];

          lualine_b = [{
            name = "filename";

            separator = {
              left = "";
              right = "";
            };
          }];

          lualine_c = [ "" ];
          lualine_x = [ "" ];
          lualine_y = [ "" ];
          lualine_z = [ "" ];
        };
      };

      noice = {
        enable = true;

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

      notify = {
        enable = true;
        stages = "static";
      };

      telescope = {
        enable = true;

        extensions = {
          fzf-native.enable = true;
          media-files.enable = true;
        };

        keymaps = { "<C-p>".action = "find_files"; };
      };

      transparent = {
        enable = true;
        settings.groups =
          [ "StatusLine" "StatusLineNC" "Pmenu" "Float" "NormalFloat" ];
      };

      treesitter = {
        enable = true;
        ensureInstalled = [
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
          "haskell"
          "c_sharp"
          "regex"
          "toml"
          "dockerfile"
          "rust"
          "typescript"
          "zig"
        ];
      };
    };

    extraPlugins = let
      lua = src: ''
        lua<<EOF
        ${src}
        EOF
      '';
    in [
      pkgs.bg-nvim
      {
        plugin = pkgs.vimPlugins.overseer-nvim;
        config = lua ''require("overseer").setup({})'';
      }
    ];
  };
}
