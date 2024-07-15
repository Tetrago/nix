{ inputs, lib, pkgs, ... }:

{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  home.packages = with pkgs; [
    xxd
  ];

  programs.nixvim = {
    enable = true;

    opts = {
      number = true;
      relativenumber = true;

      expandtab = true;
      tabstop = 4;
      shiftwidth = 4;

      mousemodel = "extend";
    };

    colorschemes.vscode.enable = true;
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
      (mkCommand "t" "NvimTreeToggle")
      (mkCommand "g" "Neogit")
      (mkCommand "d" "lua require('dapui').toggle()")
      (mkCommand "f" "Telescope live_grep")
      (mkAction "<F5>" "DapContinue")
      (mkAction "<F6>" "make")
      (mkAction "<F9>" "DapToggleBreakpoint")
      (mkAction "<F10>" "DapStepOver")
      (mkAction "<F11>" "DapStepInto")
      (mkAction "<F12>" "DapStepOut")
      (mkAction "-" "Oil")
      (mkAction "=" "ClangdSwitchSourceHeader")
    ] ++ (lib.attrsets.mapAttrsToList (key: value: {
      mode = [ "n" "x" "o" ];
      inherit key;
      options.silent = true;
      action = value;
    }) {
      s = "<Plug>(leap-forward)";
      S = "<Plug>(leap-backward)";
      gs = "<Plug>(leap-from-window)";
    });

    plugins = {
      autoclose.enable = true;
      auto-session.enable = true;
      barbecue.enable = true;
      clangd-extensions.enable = true;
      coq-thirdparty.enable = true;
      fidget.enable = true;
      fugitive.enable = true;
      illuminate.enable = true;
      indent-blankline.enable = true;
      lspkind.enable = true;
      lsp-format.enable = true;
      lsp-status.enable = true;
      lualine.enable = true;
      neogit.enable = true;
      neoscroll.enable = true;
      nix.enable = true;
      notify.enable = true;
      nvim-colorizer.enable = true;
      nvim-tree.enable = true;
      oil.enable = true;
      surround.enable = true;
      treesitter-context.enable = true;

      coq-nvim = {
        enable = true;
        settings.auto_start = true;
      };

      dap = {
        enable = true;
        adapters.executables = let
          gdb = {
            command = "gdb";
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
        signs.dapBreakpoint.text = "•";
        extensionConfigLua = ''
          local dap, dapui = require("dap"), require("dapui")
          dap.listeners.before.attach.dapui_config = dapui.open
          dap.listeners.before.launch.dapui_config = dapui.open
          dap.listeners.before.event_terminated.dapui_config = dapui.close
          dap.listeners.before.event_exited.dapui_config = dapui.close
        '';
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

      noice = {
        enable = true;
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

      telescope = {
        enable = true;
        keymaps = {
          "<C-p>".action = "find_files";
        };
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
      lua = src: "lua<<EOF\n${src}\nEOF";
    in with pkgs.vimPlugins; [
      {
        plugin = hex-nvim;
        config = lua "require('hex').setup()";
      }
    ];
  };
}
