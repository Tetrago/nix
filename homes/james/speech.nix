{ lib, pkgs, ... }:

let
  mkVoice =
    {
      name,
      quality ? "medium",
      onnxHash,
      jsonHash,
    }:
    pkgs.stdenvNoCC.mkDerivation {
      name = "piper-${name}-${quality}";

      src1 = pkgs.fetchurl {
        url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/${name}/${quality}/en_US-${name}-${quality}.onnx";
        sha256 = onnxHash;
      };

      src2 = pkgs.fetchurl {
        url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/${name}/${quality}/en_US-${name}-${quality}.onnx.json";
        sha256 = jsonHash;
      };

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out
        cp $src1 $out/en_US-${name}-${quality}.onnx
        cp $src2 $out/en_US-${name}-${quality}.onnx.json
      '';
    };

  libritts_r = mkVoice {
    name = "libritts_r";
    jsonHash = "sha256-tHHcYNLYM16BnDk9GW1vv3koF/QAUSV7Jph4UFvJr7M=";
    onnxHash = "sha256-ELuF4HHWFvz0Bx82nxeZ0EkUkqs8XVUuwZ+1SPrBMZU=";
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
