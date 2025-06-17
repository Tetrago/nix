{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) hashString toJSON;
  inherit (lib) getExe mkEnableOption mkIf;
  inherit (lib.attrsets) mapAttrs mapAttrsToList recursiveUpdate;
  inherit (lib.strings) concatLines concatStringsSep;

  package =
    let
      product = "$out/lib/vscode/resources/app/product.json";
      workbench = "$out/lib/vscode/resources/app/out/vs/code/electron-sandbox/workbench/workbench.html";

      calculateHash = pkgs.writeShellScriptBin "calculateHash" ''
        sha256sum "$1" | awk '{ print $1 }' | ${getExe pkgs.xxd} -r -p | base64 | sed 's/=*$//'
      '';
    in
    pkgs.vscodium.overrideAttrs (
      final: prev: {
        nativeBuildInputs = prev.nativeBuildInputs or [ ] ++ [
          calculateHash
          pkgs.makeWrapper
        ];

        postInstall = ''
          ${prev.postInstall or ""}

          original_checksum=$(calculateHash "${workbench}")

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

          modified_checksum=$(calculateHash "${workbench}")

          substituteInPlace "${product}" \
            --replace-fail "$original_checksum" "$modified_checksum"

          wrapProgram $out/bin/codium \
            --prefix PATH : ${
              lib.makeBinPath (
                with pkgs;
                [
                  nil
                  nixfmt-rfc-style
                ]
              )
            }
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
                  alefragnani.project-manager
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
                    name = "oil-code";
                    publisher = "haphazarddev";
                    version = "0.0.21";
                    hash = "sha256-Kcb9k3RmkDErBPTijcbCGij+ly3bQ5DDUnXEt/kHqU0=";
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
                "extensions.experimental.affinity"."vscodevim.vim" = 1;

                "files.exclude" = {
                  "**/.direnv" = true;
                  "**/.envrc" = true;
                };

                "security.workspace.trust.enabled" = false;
                "material-icon-theme.activeIconPack" = "none";

                "nix.enableLanguageServer" = true;
                "nix.serverPath" = "nil";
                "nix.serverSettings".nil.formatting.command = [ "nixfmt" ];

                "oil-code.disableDefaultKeymaps" = true; # Don't work
                "oil-code.hasNerdFont" = true;

                "projectManager.git.baseFolders" = [ "~/Projects" ];

                "vim.easymotion" = true;
                "vim.handleKeys" = {
                  "<C-p>" = false;
                };
                "vim.normalModeKeyBindings" = [
                  {
                    before = [ "-" ];
                    commands = [ { command = "oil-code.open"; } ];
                  }
                  {
                    before = [ "<CR>" ];
                    commands = [ { command = "oil-code.select"; } ];
                  }
                ];

                "window.autoDetectColorScheme" = true;
                "window.commandCenter" = false;

                "workbench.editor.editorActionsLocation" = "hidden";
                "workbench.editor.enablePreview" = false;
                "workbench.editor.limit.enabled" = true;
                "workbench.editor.limit.perEditorGroup" = true;
                "workbench.editor.limit.value" = 1;
                "workbench.editor.showTabs" = "single";
                "workbench.editor.customLabels.enabled" = true;
                "workbench.editor.customLabels.patterns" = {
                  "**/mod.rs" = "\${dirname}";
                  "**/default.nix" = "\${dirname}";
                };

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

              keybindings = [
                {
                  key = "ctrl+shift+b";
                  command = "-workbench.action.tasks.build";
                  when = "taskCommandsRegistered";
                }
                {
                  key = "f6";
                  command = "-workbench.action.debug.pause";
                  when = "debugState == 'running'";
                }
                {
                  key = "f6";
                  command = "-workbench.action.focusNextPart";
                }
                {
                  key = "f6";
                  command = "workbench.action.tasks.build";
                  when = "taskCommandsRegistered";
                }
                {
                  key = "ctrl+shift+`";
                  command = "-workbench.action.terminal.new";
                  when = "terminalProcessSupported || terminalWebExtensionContributedProfile";
                }
                {
                  key = "ctrl+`";
                  command = "-workbench.action.terminal.toggleTerminal";
                  when = "terminal.active";
                }
                {
                  key = "ctrl+\\";
                  command = "-workbench.action.splitEditor";
                }
                {
                  key = "ctrl+\\";
                  command = "workbench.action.terminal.toggleTerminal";
                  when = "terminal.active";
                }
                {
                  key = "ctrl+j";
                  command = "-extension.vim_ctrl+j";
                  when = "editorTextFocus && vim.active && vim.use<C-j> && !inDebugRepl";
                }
                {
                  key = "ctrl+j";
                  command = "-workbench.action.togglePanel";
                }
                {
                  key = "ctrl+j";
                  command = "projectManager.listProjects";
                }
              ];
            };
          in
          mapAttrs
            (
              _: v:
              recursiveUpdate common (
                v
                // {
                  extensions = v.extensions or [ ] ++ common.extensions;
                  keybindings = v.keybindings or [ ] ++ common.keybindings;
                }
              )
            )
            {
              Rust = {
                extensions = with pkgs.vscode-extensions; [
                  fill-labs.dependi
                  rust-lang.rust-analyzer
                  vadimcn.vscode-lldb
                ];

                userSettings = {
                  "editor.semanticTokenColorCustomizations".rules."*.mutable".fontStyle = "italic";
                  "rust-analyzer.check.command" = "clippy";
                  "[rust]"."editor.defaultFormatter" = "rust-lang.rust-analyzer";
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

            "workbench.statusbar.hidden" = [
              "status.notifications"
              "esbenp.prettier-vscode.prettier.status"
              "kamikillerto.vscode-colorize"
              "status.editor.eol"
              "status.editor.encoding"
              "status.editor.indentation"
              "mhutchie.git-graph"
            ];

            "workbench.activity.showAccounts" = false;
          };

          mkState =
            values:
            pkgs.runCommand "state-${hashString "sha256" (toJSON values)}.vscdb" { } ''
              ${getExe pkgs.sqlite} "$out" <<EOF
              CREATE TABLE ItemTable (key TEXT UNIQUE ON CONFLICT REPLACE, value BLOB);
              INSERT OR REPLACE INTO ItemTable (key, value)
              VALUES ${concatStringsSep "," (mapAttrsToList (n: v: "('${n}', '${toJSON v}')") values)};
              EOF
            '';
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] (
          concatLines (
            map
              (n: ''
                run mkdir -p "$(dirname "$XDG_CONFIG_HOME/${n}")"
                run rm -f "$XDG_CONFIG_HOME/${n}"
                run touch "$(dirname "$XDG_CONFIG_HOME/${n}")/storage.json"
                run cp "${mkState values}" "$XDG_CONFIG_HOME/${n}"
              '')
              (
                [ "VSCodium/User/globalStorage/state.vscdb" ]
                ++ map (n: "VSCodium/User/profiles/${n}/globalStorage/state.vscdb") [ "Rust" ]
              )
          )
        );
    };
}
