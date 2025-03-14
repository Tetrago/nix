{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption mkMerge;
  inherit (lib.attrsets) mapAttrsToList genAttrs;
in
{
  options.james.media = {
    enable = mkEnableOption "media applications and mime configurations.";
    enableNixlandIntegration = mkEnableOption "nixland window rules.";
  };

  config =
    let
      cfg = config.james.media;
    in
    mkIf cfg.enable {
      dconf.settings."com/github/neithern/g4music" = {
        audio-sink = "pulsesink";
        music-dir = "file://${config.xdg.userDirs.music}";
        peak-characters = "•";
      };

      home.packages = with pkgs; [
        decibels
        exhibit
        file-roller
        g4music
        gnome-font-viewer
        typora
      ];

      programs = {
        beets = {
          enable = true;
          settings = {
            library = "${config.xdg.userDirs.music}/.library.db";

            paths = {
              default = "$album/$title";
              comp = "$album/$title";
              singleton = "$title/$title";
            };

            plugins = [
              "fetchart"
              "thumbnails"
            ];
          };
        };

        feh = {
          enable = true;

          buttons = {
            prev_img = "";
            next_img = "";
            zoom_in = 4;
            zoom_out = 5;
          };
        };

        mpv = {
          enable = true;

          config = {
            osd-bar = "no";
            border = "no";
          };

          scripts = with pkgs.mpvScripts; [
            mpris
            uosc
            thumbfast
          ];
        };

        zathura.enable = true;
      };

      xdg =
        let
          desktopEntries = {
            decibels = {
              name = "Decibels";
              type = "Application";
              exec = "org.gnome.Decibels %U";
              icon = "org.gnome.Decibels";
              categories = [
                "GNOME"
                "GTK"
                "Music"
                "Audio"
                "AudioVideo"
              ];
              startupNotify = true;
              terminal = false;
              noDisplay = true;
              mimeType = [
                "audio/aac"
                "audio/x-aac"
                "audio/vnd.dolby.heaac.1"
                "audio/vnd.dolby.heaac.2"
                "audio/aiff"
                "audio/x-aiff"
                "audio/m4a"
                "audio/x-m4a"
                "application/x-extension-m4a"
                "audio/mp1"
                "audio/x-mp1"
                "audio/mp2"
                "audio/x-mp2"
                "audio/mp3"
                "audio/x-mp3"
                "audio/mpeg"
                "audio/mpeg2"
                "audio/mpeg3"
                "audio/mpegurl"
                "audio/x-mpegurl"
                "audio/mpg"
                "audio/x-mpg"
                "audio/rn-mpeg"
                "audio/musepack"
                "audio/x-musepack"
                "audio/ogg"
                "audio/scpls"
                "audio/x-scpls"
                "audio/vnd.rn-realaudio"
                "audio/wav"
                "audio/x-pn-wav"
                "audio/x-pn-windows-pcm"
                "audio/x-realaudio"
                "audio/x-pn-realaudio"
                "audio/x-ms-wma"
                "audio/x-pls"
                "audio/x-wav"
              ];
            };

            exhibit = {
              name = "Exhibit";
              type = "Application";
              exec = "exhibit %U";
              icon = "io.github.nokse22.Exhibit";
              categories = [
                "GTK"
                "Graphics"
                "Science"
                "3DGraphics"
                "Viewer"
                "GNOME"
              ];
              startupNotify = true;
              terminal = false;
              noDisplay = true;
              mimeType = [
                "model/3mf"
                "model/step"
                "model/obj"
                "model/stl"
                "application/octet-stream"
                "model/x-other"
                "application/vnd.ms-3mfdocument"
                "application/prs.wavefront-obj"
                "model/gltf-binary"
                "model/gltf-json"
                "text/vnd.abc"
                "image/x-3ds"
                "image/tiff"
                "model/iges"
                "application/gml+xml"
                "image/vnd.dxf"
              ];
            };

            feh = {
              name = "Feh";
              exec = "feh --scale-down --start-at %U";
              terminal = false;
              mimeType = [
                "image/bmp"
                "image/gif"
                "image/jpeg"
                "image/jpg"
                "image/pjpeg"
                "image/png"
                "image/tiff"
                "image/x-bmp"
                "image/x-pcx"
                "image/x-png"
                "image/x-portable-anymap"
                "image/x-portable-bitmap"
                "image/x-portable-graymap"
                "image/x-portable-pixmap"
                "image/x-tga"
                "image/x-xbitmap"
                "image/webp"
              ];
              noDisplay = true;
            };

            firefox = {
              categories = [
                "Network"
                "WebBrowser"
              ];
              name = "Firefox";
              genericName = "Web Browser";
              startupNotify = true;
              type = "Application";
              exec = "firefox --name firefox %U";
              terminal = false;
              mimeType = [
                "text/html"
                "text/xml"
                "application/xhtml+xml"
                "application/vnd.mozilla.xul+xml"
                "x-scheme-handler/http"
                "x-scheme-handler/https"
              ];
              icon = "firefox";
              actions = {
                "new-private-window" = {
                  exec = "firefox --private-window %U";
                  name = "New Private Window";
                };
                "new-window" = {
                  exec = "firefox --new-window %U";
                  name = "New Window";
                };
                "profile-manager-window" = {
                  exec = "firefox --ProfileManager";
                  name = "Profile Manager";
                };
              };
            };

            gnome-fonts = {
              name = "Fonts";
              icon = "org.gnome.font-viewer";
              exec = "gnome-font-viewer %u";
              terminal = false;
              type = "Application";
              startupNotify = true;
              categories = [
                "GTK"
                "GNOME"
                "Utility"
                "X-GNOME-Utilities"
              ];
              mimeType = [
                "application/x-font-ttf"
                "application/x-font-pcf"
                "application/x-font-type1"
                "application/x-font-otf"
                "font/ttf"
                "font/otf"
                "font/woff"
              ];
            };

            mpv = {
              name = "mpv Media Player";
              exec = "mpv --autofit=75%%x75%% -- %U";
              terminal = false;
              mimeType = [
                "application/ogg"
                "application/x-ogg"
                "application/mxf"
                "application/sdp"
                "application/smil"
                "application/x-smil"
                "application/streamingmedia"
                "application/x-streamingmedia"
                "application/vnd.rn-realmedia"
                "application/vnd.rn-realmedia-vbr"
                "video/mpeg"
                "video/x-mpeg2"
                "video/x-mpeg3"
                "video/mp4v-es"
                "video/x-m4v"
                "video/mp4"
                "application/x-extension-mp4"
                "video/divx"
                "video/vnd.divx"
                "video/msvideo"
                "video/x-msvideo"
                "video/ogg"
                "video/quicktime"
                "video/vnd.rn-realvideo"
                "video/x-ms-afs"
                "video/x-ms-asf"
                "audio/x-ms-asf"
                "application/vnd.ms-asf"
                "video/x-ms-wmv"
                "video/x-ms-wmx"
                "video/x-ms-wvxvideo"
                "video/x-avi"
                "video/avi"
                "video/x-flic"
                "video/fli"
                "video/x-flc"
                "video/flv"
                "video/x-flv"
                "video/x-theora"
                "video/x-theora+ogg"
                "video/x-matroska"
                "video/mkv"
                "audio/x-matroska"
                "application/x-matroska"
                "video/webm"
                "audio/webm"
                "audio/vorbis"
                "audio/x-vorbis"
                "audio/x-vorbis+ogg"
                "video/x-ogm"
                "video/x-ogm+ogg"
                "application/x-ogm"
                "application/x-ogm-audio"
                "application/x-ogm-video"
                "application/x-shorten"
                "audio/x-shorten"
                "audio/x-ape"
                "audio/x-wavpack"
                "audio/x-tta"
                "audio/AMR"
                "audio/ac3"
                "audio/eac3"
                "audio/amr-wb"
                "video/mp2t"
                "audio/flac"
                "audio/mp4"
                "application/x-mpegurl"
                "video/vnd.mpegurl"
                "application/vnd.apple.mpegurl"
                "audio/x-pn-au"
                "video/3gp"
                "video/3gpp"
                "video/3gpp2"
                "audio/3gpp"
                "audio/3gpp2"
                "video/dv"
                "audio/dv"
                "audio/opus"
                "audio/vnd.dts"
                "audio/vnd.dts.hd"
                "audio/x-adpcm"
                "application/x-cue"
                "audio/m3u"
                "audio/vnd.wave"
                "video/vnd.avi"
              ];
              noDisplay = true;
            };

            typora = {
              name = "Typora";
              exec = "typora %U";
              terminal = false;
              mimeType = [
                "text/x-markdown"
                "text/markdown"
              ];
              icon = "typora";
            };

            zathura = {
              name = "Zathura";
              exec = "zathura %f";
              terminal = false;
              mimeType = [ "application/pdf" ];
              noDisplay = true;
            };

            neovim = {
              name = "Neovim";
              exec = "ghostty -e nvim %f";
              terminal = false;
              icon = "nvim";
              noDisplay = true;
              mimeType = [
                "text/plain"
                "text/html"
                "text/css"
                "application/xml"
                "application/json"
              ];
              startupNotify = true;
            };
          };
        in
        {
          inherit desktopEntries;

          mimeApps = {
            enable = true;
            defaultApplications =
              let
                auto = mapAttrsToList (key: value: genAttrs value.mimeType (name: "${key}.desktop")) desktopEntries;
              in
              mkMerge auto;
          };
        };

      nixland.windowRules = mkIf cfg.enableNixlandIntegration [
        {
          class = "feh";
          rules = [
            "float"
            "size 75% 75%"
          ];
        }
        {
          class = "mpv";
          rules = "float";
        }
        {
          class = "com.github.neithern.g4music";
          rules = [
            "float"
            "size 350 500"
          ];
        }
        {
          class = "org.gnome.Decibels";
          rules = [
            "float"
            "size 600 400"
          ];
        }
      ];
    };

}
