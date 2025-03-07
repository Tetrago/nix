{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    getExe
    mkBefore
    mkMerge
    ;
in
{
  imports = [ ./starship.nix ];

  home = {
    file.".blerc".text = ''
      bleopt history_share=1
    '';

    packages = with pkgs; [
      somo
      scc
      duf
      dust
      pastel
      choose
      bandwhich
      tldr
    ];
  };

  programs = {
    atuin = {
      enable = true;
      enableBashIntegration = false; # Uses bash-preexec and not ble.sh
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
        hx = getExe hexyl;
        cp = "cp -i";
        mv = "mv -i";
        nnn = "xplr";
        ranger = "xplr";
        gdb = "gdb -q";
        md = getExe glow;
        math = getExe numbat;
      };

      initExtra = mkMerge [
        ''
          if [[ :$SHELLOPTS: =~ :(vi|emacs): ]]; then
            eval "$(${lib.getExe config.programs.atuin.package} init bash ${lib.escapeShellArgs config.programs.atuin.flags})"
          fi
        ''
        (mkBefore ''
          [[ $- == *i* ]] && source ${pkgs.blesh}/share/blesh/ble.sh
        '')
      ];
    };

    bat.enable = true;
    eza.enable = true;
    ripgrep.enable = true;
    xplr.enable = true;
  };
}
