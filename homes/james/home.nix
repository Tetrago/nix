{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/hyprland.nix
    ../../modules/home-manager/neovim.nix
  ];

  config = {
    hyprland.background.enable = true;
    hyprland.background.wallpaper = "~/.wallpaper.jpg";

    home = {
      username = "james";
      homeDirectory = "/home/james";

      packages = with pkgs; [
        neofetch
	p7zip
	eza
	bat
	ripgrep
	fd
	hexyl
	tre
	xplr
	scc
	ghidra
	burpsuite
	openvpn
	cyberchef
      ];

      sessionVariables = {
        TERMINAL = "alacritty";
        EDITOR = "nvim";
	MANPAGER = "sh -c 'col -bx | bat -l man -p'";
	MANROFFOPT = "-c";
      };

      stateVersion = "23.11";
    };

    programs = {
      alacritty = {
        enable = true;
        settings = {
	  shell = {
	    program = "/usr/bin/env";
	    args = [ "bash" "-l" ];
	  };

	  font = {
	    size = 11;

	    bold = {
	      family = "Fira Code";
	      style = "Bold";
	    };

	    normal = {
	      family = "Fira Code";
	      style = "Regular";
	    };
	  };

	  keyboard.bindings = [
	    {
	      action = "SpawnNewInstance";
	      key = "N";
	      mods = "Control";
	    }
	  ];

	  window = {
	    opacity = 0.9;
	    padding = {
	      x = 5;
	      y = 5;
	    };
	  };

	  colors = {
	    bright = {
	      black = "#4c566a";
	      blue = "#81a1c1";
	      cyan = "#8fbcbb";
	      green = "#a3be8c";
	      magenta = "#b48ead";
	      red = "#bf616a";
	      white = "#eceff4";
	      yellow = "#ebcb8b";
	    };

	    cursor = {
	      cursor = "#d8dee9";
	      text = "#2e3440";
	    };

	    dim = {
	      black = "#373e4d";
	      blue = "#68809a";
	      cyan = "#6d96a5";
	      green = "#809575";
	      magenta = "#8c738c";
	      red = "#94545d";
	      white = "#aeb3bb";
	      yellow = "#b29e75";
	    };

	    normal = {
	      black = "#3b4252";
	      blue = "#81a1c1";
	      cyan = "#88c0d0";
	      green = "#a3be8c";
	      magenta = "#b48ead";
	      red = "#bf616a";
	      white = "#e5e9f0";
	      yellow = "#ebcb8b";
	    };

	    primary = {
	      background = "#2e3440";
	      dim_foreground = "#a5abb6";
	      foreground = "#d8dee9";
	    };

	    search.matches = {
	      background = "#88c0d0";
	      foreground = "CellBackground";
	    };

	    selection = {
	      background = "#4c566a";
	      text = "CellForeground";
	    };

	    vi_mode_cursor = {
	      cursor = "#d8dee9";
	      text = "#2e3440";
	    };
	  };
	};
      };
      bash = {
        enable = true;
	enableCompletion = true;
	shellAliases = {
	  ls = "eza";
	  ll = "eza -lh";
	  la = "eza -alh";
	  grep = "grep --color=auto";
	  ip = "ip -color=auto";
	  cat = "bat -Pu";
	  hx = "hexyl";
	  cp = "cp -i";
	  mv = "mv -i";
	  tree = "tre";
	  nnn = "xplr";
	  ranger = "xplr";
	  cloc = "scc";
	};
      };
      firefox = let
        userChrome = builtins.readFile(builtins.fetchurl {
	  url = "https://raw.githubusercontent.com/crambaud/waterfall/main/userChrome.css";
	  sha256 = "62008a97381cf0b8b57e5a0b39cf13305903f3b32e3b31fe209182bfe317affa";
	});
      in {
        enable = true;
	profiles.default = {
	  userChrome = userChrome;
	  settings = {
	    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
	    "layers.acceleration.force-enabled" = true;
	    "gfx.webrender.all" = true;
	    "svg.context-properties.content.enabled" = true;
	  };
	};
      };
      git = {
        enable = true;
        userName = "James";
        userEmail = "tetrago@allriagon.com";
      };
      starship = {
        enable = true;
        settings = {
          add_newline = false;
          right_format = "$time";
          time = {
            disabled = false;
            style = "bold bright-black";
            format = "[$time]($style)";
          };
        };
      };
      home-manager.enable = true;
    };
  };
}
