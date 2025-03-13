{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
in
{
  imports = [ inputs.nixcord.homeManagerModules.nixcord ];

  options.james.discord = {
    enable = mkEnableOption "Discord configuration.";
    enableNixlandIntegration = mkEnableOption "nixland window rules for Discord.";
  };

  config =
    let
      cfg = config.james.discord;
    in
    mkMerge [
      (mkIf cfg.enable {
        home.file =
          let
            inherit (config.programs.nixcord.vesktop) configDir;
            inherit (pkgs) fetchurl;
          in
          {
            "${configDir}/themes/SettingsModal.theme.css".source = fetchurl {
              url = "https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/78a664992c9dc21dcd7b49c7602f32814b488632/Themes/SettingsModal/SettingsModal.theme.css";
              sha256 = "sha256-ib6y+L5uD+y27THA4OwrIKulgC3otrwZidGRtFdIHWc=";
            };

            "${configDir}/themes/RadialStatus.theme.css".source = fetchurl {
              url = "https://raw.githubusercontent.com/DiscordStyles/RadialStatus/8444d415c44d7019708eb0a577b085141725a2df/RadialStatus.theme.css";
              sha256 = "sha256-R8dxgZovZe92n5lNNyxBTOxhuQduyszj+nrx3kafAJ4=";
            };

            "${configDir}/themes/HorizontalServerList.theme.css".source = fetchurl {
              url = "https://raw.githubusercontent.com/DiscordStyles/HorizontalServerList/d54f035f594394b05505de70ddaa699989ca7273/HorizontalServerList.theme.css";
              sha256 = "sha256-OEw+YP/XXssjJEfYgnFglpeM4AwqDETrQgYgFdVNTYE=";
            };

            "${configDir}/themes/MinimalCord.theme.css".source = fetchurl {
              url = "https://raw.githubusercontent.com/DiscordStyles/MinimalCord/2b7c6a57e49fe997d4c938c1ed28134e6192b3db/MinimalCord.theme.css";
              sha256 = "sha256-idXEKZhm0ZzZBYt/6Ts/LP2xNKJde0dYy+FDB2qSNxU=";
            };
          };

        programs.nixcord = {
          enable = true;

          quickCss = ''
            [aria-label="Direct Messages"] > li:nth-child(3) {
              display: none !important;
            }

            [aria-label="Direct Messages"] > li:nth-child(4) {
              display: none !important;
            }
          '';

          config = {
            useQuickCss = true;

            plugins = {
              callTimer.enable = true;
              hideAttachments.enable = true;
              messageLinkEmbeds.enable = true;
              noProfileThemes.enable = true;
              onePingPerDM.enable = true;
              reverseImageSearch.enable = true;
              silentTyping.enable = true;
              translate.enable = true;
              vcNarrator.enable = true;
              webScreenShareFixes.enable = true;
              whoReacted.enable = true;

              betterFolders = {
                enable = true;
                sidebar = false;
                sidebarAnim = false;
                closeAllFolders = true;
                closeAllHomeButton = true;
                closeOthers = true;
                forceOpen = true;
              };

              messageClickActions = {
                enable = true;
                enableDeleteOnClick = false;
              };

              sendTimestamps = {
                enable = true;
                replaceMessageContents = false;
              };
            };
          };

          extraConfig = {
            enabledThemes = [
              "HorizontalServerList.theme.css"
              "MinimalCord.theme.css"
              "RadialStatus.theme.css"
              "SettingsModal.theme.css"
            ];
          };

          discord.enable = false;

          vesktop = {
            enable = true;
            settings.tray = false;
          };
        };

        xdg = {
          desktopEntries = {
            discord = {
              name = "Discord";
              type = "Application";
              exec = "vesktop %U";
              icon = "discord";
              categories = [
                "Network"
                "InstantMessaging"
              ];
              mimeType = [
                "x-scheme-handler/discord"
              ];
            };

            vesktop = {
              name = "Vesktop";
              type = "Application";
              exec = "vesktop %U";
              icon = "vesktop";
              categories = [
                "Network"
                "InstantMessaging"
              ];
              noDisplay = true;
            };
          };

          mimeApps.defaultApplications."x-scheme-handler/discord" = "discord.desktop";
        };
      })
      (mkIf (cfg.enable && cfg.enableNixlandIntegration) {
        nixland.windowRules = [
          {
            title = "vesktop";
            rules = "workspace special:hidden silent";
          }
        ];
      })
    ];
}
