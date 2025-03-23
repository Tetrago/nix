{
  renderdoc,
  stdenvNoCC,
  vulkan-validation-layers,
}:

stdenvNoCC.mkDerivation {
  pname = "renderdoc-x11";
  inherit (renderdoc) version;

  dontUnpack = true;
  dontBuild = true;

  installPhase =
    let
      cmd = "VK_LAYER_PATH=${vulkan-validation-layers}/share/vulkan/explicit_layer.d env -u WAYLAND_DISPLAY ${renderdoc}/bin/qrenderdoc %f";
    in
    ''
      mkdir -p $out/share/applications
      cp ${renderdoc}/share/applications/renderdoc.desktop $out/share/applications/renderdoc-x11.desktop
      cp --no-preserve=mode -rL ${renderdoc}/share/icons $out/share/icons

      substituteInPlace $out/share/applications/renderdoc-x11.desktop \
        --replace-fail "Exec=qrenderdoc" "Exec=sh -c '${cmd}'"
    '';
}
