{
  renderdoc,
  stdenvNoCC
}:

stdenvNoCC.mkDerivation {
  pname = "renderdoc-x11";
  inherit (renderdoc) version;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/applications
    cp ${renderdoc}/share/applications/renderdoc.desktop $out/share/applications/renderdoc.desktop
    sed -i 's@Exec=.*@Exec=env -u WAYLAND_DISPLAY ${renderdoc}/bin/qrenderdoc %f /@g' $out/share/applications/renderdoc.desktop
  '';
}
