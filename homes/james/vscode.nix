{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) getExe mkEnableOption mkIf;
  inherit (lib.attrsets) mapAttrs recursiveUpdate;
  inherit (lib.strings) concatLines;

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
                  {
                    name = "vsnetrw";
                    publisher = "danprince";
                    version = "0.3.1";
                    hash = "sha256-rxbpxRv6h8LIrLlpusSvBbeaAP4AwRkZTTcFeVukKLc=";
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
                #     color = "blue-400";
                #     fileNames = [ "mod.rs" ];
                #   }
                #   {
                #     name = "rust-lib";
                #     base = "rust";
                #     color = "light-green-300";
                #     lightColor = "light-green-600";
                #     fileNames = [ "lib.rs" ];
                #   }
                # ];

                "nix.formatterPath" = getExe pkgs.nixfmt-rfc-style;

                "vim.easymotion" = true;
                "vim.normalModeKeyBindings" = [
                  {
                    "before" = [ "-" ];
                    "commands" = [ "vsnetrw.open" ];
                    "when" = "editorLangId != vsnetrw";
                  }
                ];
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

      home.activation.vscode = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        concatLines (
          map
            (
              n:
              let
                path = "$XDG_CONFIG_HOME/${n}";
              in
              with pkgs.vscode-extensions;
              ''
                run rm -f "${path}"
                run mkdir -p "$(dirname "${path}")"

                run ${getExe pkgs.sqlite} "${path}" <<EOF
                CREATE TABLE ItemTable (key TEXT UNIQUE ON CONFLICT REPLACE, value BLOB);

                INSERT OR REPLACE INTO ItemTable (key, value)
                VALUES
                  ('extensionKeys/alefragnani.project-manager@${alefragnani.project-manager.version}','["project-manager.version"]'),
                  ('alefragnani.project-manager','{"project-manager.version":"${alefragnani.project-manager.version}"}'),
                  ('extensionKeys/fill-labs.dependi@${fill-labs.dependi.version}','["dependi.shownVersion"]'),
                  ('fill-labs.dependi','{"dependi.shownVersion":"${fill-labs.dependi.version}"}'),
                  ('workbench.explorer.views.state.hidden','[{"id":"outline","isHidden":true},{"id":"timeline","isHidden":true},{"id":"workbench.explorer.openEditorsView","isHidden":true},{"id":"workbench.explorer.fileView","isHidden":false},{"id":"npm","isHidden":true},{"id":"rustDependencies","isHidden":true}]'),
                  ('workbench.activity.pinnedViewlets2','[{"id":"workbench.view.search","visible":false},{"id":"workbench.view.extensions","visible":false},{"id":"workbench.view.extension.project-manager","visible":false}]'),
                  ('workbench.scm.views.state.hidden','[{"id":"workbench.scm.repositories","isHidden":true},{"id":"workbench.scm","isHidden":false},{"id":"workbench.scm.history","isHidden":true}]'),
                  ('workbench.activity.showAccounts', 'false');
                EOF
              ''
            )
            [
              "VSCodium/User/globalStorage/state.vscdb"
              "VSCodium/User/profiles/Rust/globalStorage/state.vscdb"
            ]
        )
      );
    };
}
