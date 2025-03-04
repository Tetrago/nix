{ lib, pkgs, ... }:

let
  libritts_r = pkgs.stdenvNoCC.mkDerivation {
    name = "piper-libritts_r-medium";

    src1 = pkgs.fetchurl {
      url = "https://huggingface.co/rhasspy/piper-voices/raw/293cad0539066f86e6bce3b9780c472cc9157489/en/en_US/libritts_r/medium/en_US-libritts_r-medium.onnx";
      sha256 = "sha256-ELuF4HHWFvz0Bx82nxeZ0EkUkqs8XVUuwZ+1SPrBMZU=";
    };

    src2 = pkgs.fetchurl {
      url = "https://huggingface.co/rhasspy/piper-voices/raw/293cad0539066f86e6bce3b9780c472cc9157489/en/en_US/libritts_r/medium/en_US-libritts_r-medium.onnx.json";
      sha256 = "sha256-tHHcYNLYM16BnDk9GW1vv3koF/QAUSV7Jph4UFvJr7M=";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out
      cp $src1 $out/en_US-libritts_r-medium.onnx
      cp $src2 $out/en_US-libritts_r-medium.onnx.json
    '';
  };
in
{
  xdg.configFile = {
    "speech-dispatcher/speechd.conf".text = ''
      AddModule "piper-tts-generic" "sd_generic" "piper-tts-generic.conf"
    '';

    "speech-dispatcher/modules/piper-tts-generic.conf".text = ''
      GenericExecuteSynth "export XDATA=\'$DATA\'; echo \"$XDATA\" | sed -z 's/\\n/ /g' | ${lib.getExe pkgs.piper-tts} -q -m ${libritts_r}/en_US-libritts_r-medium.onnx -s 21 -f - | mpv --volume=80 --no-terminal --keep-open=no -"

      AddVoice "en-US" "MALE1"   "en_US-lessac-medium"
    '';
  };
}
