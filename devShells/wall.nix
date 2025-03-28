{
  lib,
  gowall,
  jq,
  mkShell,
  writeShellScriptBin,
  vulkan-loader,
}:

let
  gw = writeShellScriptBin "gw" ''${gowall}/bin/gowall "$@"'';

  wrap = writeShellScriptBin "wrap" ''
    file=$(mktemp /tmp/theme.XXXXXX.json)

    {
    echo "{\"name\":\"Autogenerated\",\"colors\":["

    count=0
    while read -r line; do
      if [ $count -gt 0 ]; then
        echo ","
      fi

      echo "\"$line\""
      ((count++))
    done

    echo "]}"
    } | ${lib.getExe jq} '.' > "$file"

    echo "$file"
  '';
in
mkShell {
  packages = [
    gw
    gowall
    wrap
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${vulkan-loader}/lib:$LD_LIBRARY_PATH
  '';
}
