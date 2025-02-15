{ pkgs, lib, ... }:

let
  inherit (lib) getExe;
in
{
  imports = [ ./starship.nix ];

  home.packages = with pkgs; [
    somo
    scc
    duf
    dust
    pastel
    choose
    bandwhich
    tldr
  ];

  programs = {
    atuin = {
      enable = true;
      enableBashIntegration = true;
      flags = [ "--disable-up-arrow" ];
    };

    bash = {
      enable = true;
      enableCompletion = true;

      sessionVariables = {
        EDITOR = "nvim";
        MANPAGER = "sh -c 'col -bx | ${getExe pkgs.bat} -l man -p'";
        MANROFFOPT = "-c";
      };

      shellAliases = with pkgs; {
        ls = "eza";
        ll = "eza -lh";
        la = "eza -alh";
        grep = "grep --color=auto";
        ip = "ip -color=auto";
        cat = "bat -Pu";
        cd = "z";
        hx = getExe hexyl;
        cp = "cp -i";
        mv = "mv -i";
        tree = getExe tre-command;
        nnn = "xplr";
        ranger = "xplr";
        gdb = "gdb -q";
        md = getExe glow;
        ps = getExe procs;
        math = getExe numbat;
      };
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    bat.enable = true;
    eza.enable = true;
    ripgrep.enable = true;
    xplr.enable = true;
  };
}
