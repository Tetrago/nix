{
  binaryninja-unwrapped,
  buildFHSEnv,
}:

buildFHSEnv {
  name = "binaryninja";
  runScript = "binaryninja";

  targetPkgs =
    pkgs: with pkgs; [
      binaryninja-unwrapped
      (python3.withPackages (p: with p; [ torch ]))
    ];

  multiPkgs =
    let
      xorgDeps =
        pkgs: with pkgs.xorg; [
          libX11
          libxcb
          xcbutilimage
          xcbutilkeysyms
          xcbutilrenderutil
          xcbutilwm
        ];
    in
    pkgs:
    with pkgs;
    [
      dbus
      fontconfig
      freetype
      libGL
      libxkbcommon
      libxml2
      wayland
      zlib
    ]
    ++ xorgDeps pkgs;

  extraInstallCommands = ''
    mkdir -p $out/share
    ln -s ${binaryninja-unwrapped}/share/applications $out/share/applications
  '';
}
