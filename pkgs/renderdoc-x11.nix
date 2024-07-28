{
  renderdoc,
  stdenvNoCC,
  vulkan-validation-layers
}:

stdenvNoCC.mkDerivation {
  pname = "renderdoc-x11";
  inherit (renderdoc) version;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/applications
    cp ${renderdoc}/share/applications/renderdoc.desktop $out/share/applications/renderdoc-x11.desktop
    sed -i 's@Exec=.*@Exec=VK_LAYER_PATH=${vulkan-validation-layers}/share/vulkan/explicit_layer.d env -u WAYLAND_DISPLAY ${renderdoc}/bin/qrenderdoc %f@g' $out/share/applications/renderdoc-x11.desktop
  '';
}
