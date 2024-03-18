{ config, inputs, pkgs, ... }:

{
  imports = [
    inputs.nix-colors.homeManagerModules.default

    ../../modules/home-manager/hyprworld
    ../../modules/home-manager/neovim.nix
  ];

  config = {
    hyprworld = {
      bluetooth.enable = true;
      background = {
        enable = true;
        wallpaper = "~/.wallpaper.jpg";
      };
    };

    colorScheme = let lb = inputs.nix-colors.lib.contrib { inherit pkgs; }; in lb.colorSchemeFromPicture {
      path = ./wallpaper.jpg;
      variant = "dark";
    };

    #colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;

    gtk = {
      enable = true;
      theme = {
        name = "base16-flat-${config.colorScheme.slug}-gtk";
        package = import ../../pkgs/base16-flat-gtk.nix {
	  theme = config.colorScheme.slug;
	  colors = config.colorScheme.palette;
	  inherit pkgs;
	};
      };
      iconTheme = {
        name = "kora-pgrey";
	package = pkgs.kora-icon-theme;
      };
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
    };

    home = {
      username = "james";
      homeDirectory = "/home/james";

      pointerCursor = {
        name = "capitaine-cursors";
	package = pkgs.capitaine-cursors;
        gtk.enable = true;
      };

      file.".wallpaper.jpg".source = ./wallpaper.jpg;

      packages = with pkgs; [
        neofetch
	p7zip
	fd
	hexyl
	tre
	scc
	burpsuite
	openvpn
	cyberchef
	gtk-engine-murrine
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
      bat.enable = true;
      eza.enable = true;
      ripgrep.enable = true;
      xplr.enable = true;
      zoxide = {
        enable = true;
	enableBashIntegration = true;
	options = [ "--no-cmd" ];
      };
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

	  colors = let c = config.colorScheme.palette; f = col: "0x${col}"; in {
	    primary = {
	      background = f c.base00;
	      foreground = f c.base05;
	    };

	    cursor = {
	      text = f c.base00;
	      cursor = f c.base05;
	    };

	    normal = {
	      black = f c.base00;
	      red = f c.base08;
	      green = f c.base0B;
	      yellow = f c.base0A;
	      blue = f c.base0D;
	      magenta = f c.base0E;
	      cyan = f c.base0C;
	      white = f c.base05;
	    };

	    bright = {
	      black = f c.base03;
	      red = f c.base08;
	      green = f c.base0B;
	      yellow = f c.base0A;
	      blue = f c.base0D;
	      magenta = f c.base0E;
	      cyan = f c.base0C;
	      white = f c.base07;
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

    services = {
      easyeffects.enable = true;
    };
  };
}
