{
  config,
  lib,
  ...
}:

let
  inherit (builtins)
    attrNames
    length
    genList
    listToAttrs
    ;
  inherit (lib) mkIf mkOption types;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) zipLists;
in
{
  options.garden = {
    keybindings = mkOption {
      type =
        with types;
        attrsOf (submodule {
          options = {
            binding = mkOption { type = str; };
            command = mkOption { type = str; };
          };
        });
      default = {
        firefox = {
          binding = "<Super>N";
          command = "firefox";
        };
        terminal = {
          binding = "<Super>Return";
          command = "ghostty";
        };
        explorer = {
          binding = "<Super>E";
          command = "nautilus";
        };
      };
    };
  };

  config =
    let
      cfg = config.garden;
    in
    mkIf cfg.enable {
      dconf.settings = {
        "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = genList (
          x: "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString x}/"
        ) (length (attrNames cfg.keybindings));
      }
      // listToAttrs (
        map
          (x: {
            name = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString x.fst}";
            value = x.snd;
          })
          (
            zipLists (genList (x: x) (length (attrNames cfg.keybindings))) (
              mapAttrsToList (name: v: v // { inherit name; }) cfg.keybindings
            )
          )
      );
    };
}
