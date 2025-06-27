pkgs:

let
  inherit (builtins) readDir stringLength substring;
  inherit (pkgs.lib.attrsets) filterAttrs mapAttrs';
in
mapAttrs' (n: _: {
  name = substring 0 (stringLength n - 4) n;
  value = pkgs.callPackage ./${n} { };
}) (filterAttrs (n: v: n != "default.nix" && v == "regular") (readDir ./.))
