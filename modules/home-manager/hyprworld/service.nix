pkgs: command: {
  Unit = {
    PartOf = [ "graphical-session.target" ];
    After = [ "graphical-session-pre.target" ];
  };

  Service = {
    ExecStart = command;
    ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
    Restart = "on-failure";
    KillMode = "mixed";
  };

  Install = {
    WantedBy = [ "hyprland-session.target" ];
  };
}