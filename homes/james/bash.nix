{ pkgs, ... }:

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

      initExtra = "${pkgs.fortune}/bin/fortune | ${pkgs.cowsay}/bin/cowsay -f stegosaurus";

      sessionVariables = {
        EDITOR = "nvim";
        MANPAGER = "sh -c 'col -bx | ${pkgs.bat} -l man -p'";
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
        hx = "${hexyl}/bin/hexyl";
        cp = "cp -i";
        mv = "mv -i";
        tree = "${tre-command}/bin/tre";
        nnn = "xplr";
        ranger = "xplr";
        "e.patch" = ''${patchelf}/bin/patchelf --set-interpreter "$(${coreutils}/bin/cat ${stdenv.cc}/nix-support/dynamic-linker)"'';
        "e.unpatch" = ''${patchelf}/bin/patchelf --set-interpreter "/lib64/ld-linux-x86-64.so.2"'';
        gdb = "gdb -q";
        md = "${glow}/bin/glow";
        ps = "${procs}/bin/procs";
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
