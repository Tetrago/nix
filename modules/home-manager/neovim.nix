{ pkgs, ... }:

{
  config = {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraLuaConfig = ''
        vim.wo.relativenumber = true

	vim.opt.expandtab = true
	vim.opt.tabstop = 4
	vim.opt.shiftwidth = 4

	vim.g.loaded_ruby_provider = 0
      '';
      plugins = with pkgs.vimPlugins; [
	{
	  plugin = nord-nvim;
	  config = "colorscheme nord";
	}
        {
	  plugin = (nvim-treesitter.withPlugins (p: [
	    p.tree-sitter-nix
	    p.tree-sitter-bash
	    p.tree-sitter-lua
	    p.tree-sitter-python
	    p.tree-sitter-json
	    p.tree-sitter-javascript
	    p.tree-sitter-c
	    p.tree-sitter-cpp
	    p.tree-sitter-cmake
	    p.tree-sitter-rust
	    p.tree-sitter-java
	    p.tree-sitter-markdown
	    p.tree-sitter-markdown_inline
	    p.tree-sitter-c_sharp
	    p.tree-sitter-regex
	  ]));
	  type = "lua";
	  config = ''
	    require("nvim-treesitter.configs").setup({
	      sync_installed = false,
	      highlight = { enable = true },
	      indent = { enable = true }
	    })
	  '';
	}
	vim-illuminate
	{
	  plugin = indent-blankline-nvim;
	  type = "lua";
	  config = "require(\"ibl\").setup()";
	}
	{
	  plugin = noice-nvim;
	  type = "lua";
	  config = ''
	    require("noice").setup({
	      lsp =  {
	        override = {
	          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
	          ["vim.lsp.util.stylize_markdown"] = true,
	          ["cmp.entry.get_documentation"] = true
	        }
	      },
	      presets = {
	        bottom_search = true,
	        command_palette = true,
	        long_message_to_split = true,
	        inc_rename = false,
	        lsp_doc_border = false
	      }
	    })
	  '';
	}
      ];
    };
  };
}
