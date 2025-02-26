{ lib, pkgs, ... }:

let
  inherit (lib.attrsets) mapAttrsToList genAttrs;
  inherit (lib) mkMerge;
in
{
  wayland.windowManager.hyprland.settings.windowrulev2 = [
    "float,class:^(feh)$"
    "float,class:^(mpv)$"
    "float,class:^(com.github.neithern.g4music)$"
    "size 350 500,class:^(com.github.neithern.g4music)$"
    "float,class:^(org.gnome.Decibels)$"
    "size 600 400,class:^(org.gnome.Decibels)$"
  ];

  home.packages = with pkgs; [
    apostrophe
    decibels
    exhibit
    file-roller
    g4music
  ];

  programs = {
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
            "audio/mpeg"
            "audio/wav"
            "audio/x-aac"
            "audio/x-aiff"
            "audio/x-ape"
            "audio/x-flac"
            "audio/x-m4a"
            "audio/x-m4b"
            "audio/x-mp1"
            "audio/x-mp2"
            "audio/x-mp3"
            "audio/x-mpg"
            "audio/x-mpeg"
            "audio/x-mpegurl"
            "audio/x-opus+ogg"
            "audio/x-pn-aiff"
            "audio/x-pn-au"
            "audio/x-pn-wav"
            "audio/x-speex"
            "audio/x-vorbis"
            "audio/x-vorbis+ogg"
            "audio/x-wavpack"
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
          exec = "feh --start-at %U";
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

        mpv = {
          name = "mpv Media Player";
          exec = "mpv -- %U";
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

        apostrophe = {
          name = "Apostrophe";
          exec = "apostrophe %U";
          terminal = false;
          mimeType = [
            "text/x-markdown"
            "text/markdown"
          ];
          icon = "org.gnome.gitlab.somas.Apostrophe";
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
          mkMerge (auto ++ [ { "application/x-terminal-emulator" = "ghostty.desktop"; } ]);
      };
    };
}
