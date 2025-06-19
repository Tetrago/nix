{ config, lib, ... }:

let
  inherit (lib) mkIf mkOption types;
  inherit (lib.attrsets) filterAttrs mapAttrsToList;
  inherit (lib.strings) concatLines;
in
{
  options.wondervim = {
    plugins = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
            };

            package = mkOption {
              type = types.package;
            };

            luaConfig = {
              pre = mkOption {
                type = types.str;
                default = "";
              };

              post = mkOption {
                type = types.str;
                default = "";
              };
            };

            settings = mkOption {
              type = types.attrs;
              default = { };
            };
          };
        }
      );
      default = { };
    };
  };

  config =
    let
      cfg = config.wondervim;
    in
    mkIf cfg.enable {
      extraConfigLua = concatLines (
        mapAttrsToList (n: v: ''
          do
            ${v.luaConfig.pre}
            require("${n}").setup(${lib.nixvim.lua.toLuaObject v.settings})
            ${v.luaConfig.post}
          end
        '') (filterAttrs (_: { enable, ... }: enable) cfg.plugins)
      );

      extraPlugins = mapAttrsToList (_: { package, ... }: package) (
        filterAttrs (_: { enable, ... }: enable) cfg.plugins
      );
    };
}
