{
  mkColors =
    {
      pkgs,
      path,
      style ? "dark",
    }:
    assert pkgs.lib.asserts.assertOneOf "style variant" style [
      "dark"
      "light"
    ];
    pkgs.stdenvNoCC.mkDerivation {
      name = "${builtins.baseNameOf path}-colors";
      dontUnpack = true;

      nativeBuildInputs = with pkgs; [
        flavours
      ];

      buildPhase = ''
        echo "{" > ./colors.txt
        flavours generate ${style} "${path}" --stdout | tail -n +4 | sed 's/: "\?\(......\)"\?/ = "\1";/' >> ./colors.txt
        echo "}" >> ./colors.txt
      '';

      installPhase = ''
        mkdir -p $out
        cp ./colors.txt $out/default.nix
      '';
    };
}
