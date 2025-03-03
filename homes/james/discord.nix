{ inputs, ... }:

{
  imports = [ inputs.nixcord.homeManagerModules.nixcord ];

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
      themeLinks = [
        "https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/refs/heads/master/Themes/SettingsModal/SettingsModal.theme.css"
        "https://raw.githubusercontent.com/DiscordStyles/RadialStatus/deploy/RadialStatus.theme.css"
        "https://raw.githubusercontent.com/DiscordStyles/HorizontalServerList/deploy/HorizontalServerList.theme.css"
        "https://raw.githubusercontent.com/DiscordStyles/MinimalCord/deploy/MinimalCord.theme.css"
      ];

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

  wayland.windowManager.hyprland.settings.windowrulev2 = [
    "workspace special:hidden silent,title:^(vesktop)$"
  ];
}
