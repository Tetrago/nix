{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) attrNames toJSON;
  inherit (lib)
    genAttrs
    mkEnableOption
    mkForce
    mkIf
    mkMerge
    mkOption
    recursiveUpdate
    types
    ;
  inherit (lib.asserts) assertMsg;
  inherit (lib.attrsets) filterAttrs mapAttrs;
  inherit (lib.strings) concatLines;
in
{
  options.polymorph = {
    enable = mkEnableOption "polymorph.";

    default = mkOption {
      type = types.nullOr types.str;
      apply =
        x:
        assert assertMsg (
          x == null || config.polymorph.morph ? "${x}"
        ) "Polymoprh cannot apply non-existent morph as default";
        x;
      default = null;
    };

    morph = mkOption {
      type =
        with types;
        attrsOf (submodule {
          options = {
            follows = mkOption {
              type = nullOr str;
              apply =
                x:
                assert assertMsg (
                  x == null || config.polymorph.morph ? "${x}"
                ) "Polymorph cannot follow non-existent morph";
                x;
              default = null;
            };

            substitutions = mkOption {
              type = attrsOf anything;
              default = { };
            };

            extraScripts = mkOption {
              type = coercedTo str (x: [ x ]) (listOf str);
              default = [ ];
            };
          };
        });
      default = { };
    };

    file = mkOption {
      type =
        with types;
        coercedTo (listOf str)
          (
            x:
            genAttrs x (_: {
              enable = true;
            })
          )
          (
            attrsOf (submodule {
              options = {
                enable = mkOption {
                  type = bool;
                  default = true;
                };
              };
            })
          );
      default = { };
    };

    activate = mkOption {
      type = types.attrsOf types.path;
      internal = true;
    };
  };

  config =
    let
      cfg = config.polymorph;

      resolveMorphRecursive =
        x:
        if x.follows == null then
          x
        else
          let
            parent = cfg.morph.${x.follows};
          in
          resolveMorphRecursive {
            follows = parent.follows;
            substitutions = recursiveUpdate parent.substitutions x.substitutions;
            extraScripts = parent.extraScripts ++ x.extraScripts;
          };

      files = attrNames (filterAttrs (_: v: v.enable) cfg.file);
      morphs = mapAttrs (_: resolveMorphRecursive) cfg.morph;

      mkSubstitution =
        n: v:
        pkgs.stdenvNoCC.mkDerivation rec {
          name = "polymorph-${n}";

          dontUnpack = true;

          src = pkgs.writeText "${name}.json" (toJSON v.substitutions);

          nativeBuildInputs = with pkgs; [
            gomplate
          ];

          buildPhase = concatLines (
            map (x: ''
              mkdir -p ./$(dirname ${x})
              gomplate -c .=$src -f ${config.home.file.${x}.source} -o ./${x}
            '') files
          );

          installPhase = concatLines (
            map (x: ''
              mkdir -p $out/$(dirname ${x})
              cp ./${x} $out/${x}
            '') files
          );
        };

      mkActivateScript =
        n: v:
        let
          substitution = mkSubstitution v;
        in
        pkgs.writeShellScript "polymorph-${n}-activate" (
          concatLines (map (x: "cp -f ${substitution}/${x} $HOME/${x}") files) ++ v.extraScripts
        );

      activate = mapAttrs mkActivateScript morphs;
    in
    mkIf cfg.enable {
      home = {
        activation = mkIf (cfg.default != null) (
          lib.hm.dag.entryAfter [ "writeBoundary" ] "run ${activate.${cfg.default}}"
        );

        file = mkMerge (map (x: { ${x}.enable = mkForce false; }) files);
      };

      polymorph = {
        inherit activate;
      };
    };
}
