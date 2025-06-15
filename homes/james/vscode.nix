{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) getExe mkEnableOption mkIf;
  inherit (lib.attrsets) mapAttrs mapAttrsToList recursiveUpdate;
  inherit (lib.strings) concatLines concatStringsSep;

  package =
    let
      product = "$out/lib/vscode/resources/app/product.json";
      workbench = "$out/lib/vscode/resources/app/out/vs/code/electron-sandbox/workbench/workbench.html";
    in
    pkgs.vscodium.overrideAttrs (
      final: prev: {
        postInstall = ''
          ${prev.postInstall or ""}

          calculate_hash() {
            sha256sum "$1" | awk '{ print $1 }' | ${getExe pkgs.xxd} -r -p | base64 | sed 's/=*$//'
          }

          original_checksum=$(calculate_hash "${workbench}")

          substituteInPlace "${workbench}" \
            --replace-fail "http-equiv=\"Content-Security-Policy\"" "" \
            --replace-fail "</html>" ""

          cat <<EOF >>${workbench}
            <style>
              .type.storage,.type.storage.declaration, .storage.class.modifier, .mtki {
                font-family: 'Monaspace Radon';
                font-size: 1.1em;
                font-style: normal;
              }

              .type.storage.arrow.function {
                font-family: 'Monaspace Neon';
              }

              .decorator.name, .decorator.punctuation:not(.block), .import.keyword {
                font-family: 'Monaspace Radon';
                font-size: 1.1em
                font-style: normal;
              }

              .attribute-name {
                font-family: 'Monaspace Radon';
                font-size: 1.1em
                font-style: normal;
              }

              .comment:not(.punctuation) {
                font-family: 'Monaspace Radon';
                font-size: 1.1em
                font-style: normal;
              }
            </style>
          </html>
          EOF

          modified_checksum=$(calculate_hash "${workbench}")

          substituteInPlace "${product}" \
            --replace-fail "$original_checksum" "$modified_checksum"
        '';
      }
    );
in
{
  options.james.vscode = {
    enable = mkEnableOption "VS Code config.";
  };

  config =
    let
      cfg = config.james.vscode;
    in
    mkIf cfg.enable {
      programs.vscode = {
        enable = true;
        inherit package;
        profiles =
          let
            common = {
              extensions =
                with pkgs.vscode-extensions;
                [
                  alefragnani.project-manager # Needs keybinds
                  bierner.markdown-checkbox
                  bierner.markdown-mermaid
                  editorconfig.editorconfig
                  enkia.tokyo-night
                  esbenp.prettier-vscode
                  github.github-vscode-theme
                  jnoortheen.nix-ide
                  kamikillerto.vscode-colorize
                  mhutchie.git-graph
                  mkhl.direnv
                  ms-vscode.hexeditor
                  oderwat.indent-rainbow
                  pkief.material-icon-theme
                  tamasfe.even-better-toml
                  tomoki1207.pdf
                  usernamehw.errorlens
                  vscodevim.vim
                  yzhang.markdown-all-in-one
                ]
                ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
                  {
                    name = "better-git-line-blame";
                    publisher = "mk12";
                    version = "0.2.14";
                    hash = "sha256-mPPNM8QnmZfmC3lKT8Gy4J4Old0Fpu/5TU8KKmAUiYg=";
                  }
                ];

              userSettings = {
                "betterGitLineBlame.annotateWholeLine" = true;

                "editor.fontFamily" = "'Monaspace Neon'";
                "editor.fontLigatures" = true;
                "editor.formatOnSave" = true;
                "editor.lineNumbers" = "relative";
                "editor.minimap.enabled" = false;

                "explorer.excludeGitIgnore" = true;

                "files.exclude" = {
                  "**/.direnv" = true;
                  "**/.envrc" = true;
                };

                "security.workspace.trust.enabled" = false;

                "material-icon-theme.activeIconPack" = "none";
                # "material-icon-theme.files.customClones" = [
                #   {
                #     name = "rust-mod";
                #     base = "rust";
                #     color = "light-blue-300";
                #     lightColor = "light-blue-600";
                #     fileNames = [ "mod.rs" ];
                #   }
                #   {
                #     name = "rust-lib";
                #     base = "rust";
                #     color = "light-green-300";
                #     lightColor = "light-green-600";
                #     fileNames = [ "lib.rs" ];
                #   }
                #   {
                #     name = "rust-bin";
                #     base = "rust";
                #     color = "light-red-300";
                #     lightColor = "light-red-600";
                #     fileNames = [ "bin.rs" ];
                #   }
                #   {
                #     name = "nix-default";
                #     base = "nix";
                #     color = "light-blue-300";
                #     lightColor = "light-blue-600";
                #     fileNames = [ "default.nix" ];
                #   }
                #   {
                #     name = "nix-flake";
                #     base = "nix";
                #     color = "light-green-300";
                #     lightColor = "light-green-600";
                #     fileNames = [ "flake.nix" ];
                #   }
                # ];

                "vim.easymotion" = true;
                # "vim.statusBarColorControl" = true;
                # "vim.statusBarColors.normal" = [
                #   "#8FBCBB"
                #   "#434C5E"
                # ];
                # "vim.statusBarColors.insert" = "#BF616A";
                # "vim.statusBarColors.visual" = "#B48EAD";
                # "vim.statusBarColors.visualline" = "#B48EAD";
                # "vim.statusBarColors.visualblock" = "#A3BE8C";
                # "vim.statusBarColors.replace" = "#D08770";
                # "vim.statusBarColors.commandlineinprogress" = "#007ACC";
                # "vim.statusBarColors.searchinprogressmode" = "#007ACC";
                # "vim.statusBarColors.easymotionmode" = "#007ACC";
                # "vim.statusBarColors.easymotioninputmode" = "#007ACC";
                # "vim.statusBarColors.surroundinputmode" = "#007ACC";

                "window.autoDetectColorScheme" = true;
                "window.commandCenter" = false;

                "workbench.editor.editorActionsLocation" = "hidden";
                "workbench.editor.showTabs" = "none";
                "workbench.iconTheme" = "material-icon-theme";
                "workbench.layoutControl.enabled" = false;
                "workbench.preferredDarkColorTheme" = "GitHub Dark";
                "workbench.preferredLightColorTheme" = "Tokyo Night Light";
                "workbench.startupEditor" = "none";

                "[css]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
                "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
                "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
                "[html]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
                "[scss]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
                "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
                "[yaml]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
              };
            };
          in
          mapAttrs (_: v: recursiveUpdate common (v // { extensions = v.extensions ++ common.extensions; })) {
            Rust = {
              extensions = with pkgs.vscode-extensions; [
                fill-labs.dependi
                rust-lang.rust-analyzer
                vadimcn.vscode-lldb
              ];

              userSettings = {
                "editor.semanticTokenColorCustomizations".rules."*.mutable".fontStyle = "italic";

                "[rust]" = {
                  "editor.defaultFormatter" = "rust-lang.rust-analyzer";
                };
              };
            };
          }
          // {
            default = common // {
              enableExtensionUpdateCheck = false;
              enableUpdateCheck = false;
            };
          };
      };

      home.activation.vscode =
        let
          values = with pkgs.vscode-extensions; {
            "alefragnani.project-manager"."project-manager.version" = alefragnani.project-manager.version;

            "extensionKeys/alefragnani.project-manager@${alefragnani.project-manager.version}" = [
              "project-manager.version"
            ];

            "extensionKeys/fill-labs.dependi@${fill-labs.dependi.version}" = [ "dependi.shownVersion" ];
            "fill-labs.dependi"."dependi.shownVersion" = fill-labs.dependi.version;

            "workbench.explorer.views.state.hidden" =
              map
                (id: {
                  inherit id;
                  isHidden = true;
                })
                [
                  "outline"
                  "timeline"
                  "workbench.openEditorsView"
                  "rustDependencies"
                ];

            "workbench.pinnedViewlets2" =
              map
                (id: {
                  inherit id;
                  visible = false;
                })
                [
                  "workbench.view.search"
                  "workbench.view.extensions"
                  "workbench.view.extension.project-manager"
                ];

            "workbench.scm.views.state.hidden" =
              map
                (id: {
                  inherit id;
                  isHidden = true;
                })
                [
                  "workbench.scm.repositories"
                  "workbench.scm.history"
                ];

            "workbench.activity.showAccounts" = false;
          };

          state = pkgs.runCommand "state.vscdb" { } ''
            ${getExe pkgs.sqlite} "$out" <<EOF
            CREATE TABLE ItemTable (key TEXT UNIQUE ON CONFLICT REPLACE, value BLOB);
            INSERT OR REPLACE INTO ItemTable (key, value)
            VALUES ${concatStringsSep "," (mapAttrsToList (n: v: "('${n}', '${builtins.toJSON v}')") values)};
          '';
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] (
          concatLines (
            map (n: ''
              run rm -f "$XDG_CONFIG_HOME/${n}"
              run mkdir -p "$(dirname "$XDG_CONFIG_HOME/${n}")"
              run cp "${state}" "$XDG_CONFIG_HOME/${n}"
            '') [ "VSCodium/User/globalStorage/state.vscdb" ]
            ++ map (n: "VSCodium/User/profiles/${n}/globalStorage/state.vscdb") [ "Rust" ]
          )
        );
    };
}
