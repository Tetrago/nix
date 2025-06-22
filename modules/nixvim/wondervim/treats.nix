{ config, lib, ... }:

let
  inherit (lib) mkIf mkOption types;
  inherit (lib.strings) concatStringsSep;
in
{
  options.wondervim = {
    treats = {
      bufferSkipPredicates = mkOption {
        type = with types; nullOr (listOf str);
        default = null;
        example = [
          ''
            function(win_id)
              local bufnr = vim.api.nvim_win_get_buf(winid)
              local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

              return filetype == "notify"
            end
          ''
        ];
      };
    };
  };

  config =
    let
      cfg = config.wondervim;
    in
    mkIf cfg.enable {
      autoCmd = mkIf (cfg.treats.bufferSkipPredicates != null) [
        {
          event = [ "BufEnter" ];
          pattern = "*";
          callback.__raw = ''
            (function()
              local predicates = {
                ${concatStringsSep "," cfg.treats.bufferSkipPredicates}
              }

              local function predicate()
                local win_id = vim.api.nvim_get_current_win()

                for _, v in pairs(predicates) do
                  if v(win_id) then
                    return true
                  end
                end

                return false
              end

              return function()
                local seen = {}

                while predicate() do
                  local win_id = vim.api.nvim_get_current_win()

                  if seen[win_id] then
                    return
                  else
                    vim.cmd("wincmd w")
                    seen[win_id] = true
                  end
                end
              end
            end)()
          '';
        }
      ];
    };
}
