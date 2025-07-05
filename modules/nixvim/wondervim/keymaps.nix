{ config, lib, ... }:

let
  inherit (lib) mkIf mkOption types;
in
{
  options.wondervim = {
    disableHelp = mkOption {
      type = types.bool;
      description = "Disable the F1 help bind.";
      default = true;
    };

    keymaps = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            mode = mkOption {
              type =
                let
                  enum = types.enum [
                    "n"
                    "!"
                    "i"
                    "c"
                    "v"
                    "x"
                    "s"
                    "o"
                    "t"
                    "l"
                    "!a"
                    "ia"
                    "ca"
                  ];
                in
                with types;
                coercedTo enum (x: [ x ]) (listOf enum);
              default = "n";
            };

            key = mkOption {
              type = types.str;
              example = "<C-S-f>";
            };

            lua = mkOption {
              type = with types; nullOr str;
              default = null;
            };

            command = mkOption {
              type = with types; nullOr str;
              default = null;
            };

            plug = mkOption {
              type = with types; nullOr str;
              default = null;
            };

            action = mkOption {
              type = with types; nullOr str;
              default = null;
            };

            options = mkOption {
              type = types.attrs;
              default = {
                silent = true;
              };
            };
          };
        }
      );
      default = [ ];
    };
  };

  config =
    let
      cfg = config.wondervim;
    in
    mkIf cfg.enable {
      assertions =
        map
          (
            { key, ... }:
            {
              assertion = false;
              message = "Keybind `${key}` has conflicting actions.";
            }
          )
          (
            lib.filter (
              {
                lua,
                command,
                plug,
                action,
                ...
              }:
              lib.count (x: !isNull x) [
                lua
                command
                plug
                action
              ] > 1
            ) cfg.keymaps
          );

      wondervim.keymaps = mkIf cfg.disableHelp [
        {
          mode = [
            "n"
            "i"
          ];
          key = "<F1>";
        }
      ];

      keymaps = map (
        {
          mode,
          key,
          lua,
          command,
          plug,
          action,
          options,
        }:
        {
          inherit mode key options;
          action =
            if lua != null then
              {
                __raw = ''
                  function()
                    ${lua}
                  end
                '';
              }
            else if command != null then
              "<Cmd>${command}<CR>"
            else if plug != null then
              "<Plug>(${plug})"
            else if action != null then
              action
            else
              "<Nop>";
        }
      ) cfg.keymaps;
    };
}
