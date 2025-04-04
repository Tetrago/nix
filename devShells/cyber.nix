{
  lib,
  mkShell,
  stdenv,
  stdenvNoCC,
  makeWrapper,
  burpsuite,
  binutils,
  binwalk,
  strace,
  ltrace,
  openvpn,
  metasploit,
  pwndbg,
  ghidra-bin,
  rp,
  radare2,
  python3,
  hashcat,
  john,
  stegseek,
  ffuf,
  nmap,
  netexec,
  exploitdb,
  seclists,
  sliver,
  avalonia-ilspy,
  wireshark,
  writeShellScriptBin,
  ropium,
  bloodhound-py,
  evil-winrm,
}:

let
  inherit (lib) fileContents makeLibraryPath;

  scripts = [
    (writeShellScriptBin ".q" ''
      "$@" & disown
    '')

    (writeShellScriptBin ".bs" ''
      burpsuite "$@" & disown
    '')

    (writeShellScriptBin ".s" ''
      NAME="$1"

      if [[ -z "$NAME" ]]; then
        NAME="script"
      fi

      cat <<EOF > $NAME.py
      #!/usr/bin/env python3
      EOF

      chmod +x $NAME.py
    '')
  ];

  debugger = stdenvNoCC.mkDerivation {
    name = "debugger";
    dontUnpack = true;

    nativeBuildInputs = [
      makeWrapper
    ];

    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${pwndbg}/bin/pwndbg $out/bin/debugger \
        --add-flags "--nh" \
        --add-flags "-ex 'alias -a disas = disassemble'"
    '';
  };
in
mkShell {
  name = "cyber";

  NIX_LD_LIBRARY_PATH = makeLibraryPath [ stdenv.cc.cc ];
  NIX_LD = fileContents "${stdenv.cc}/nix-support/dynamic-linker";
  SECLISTS = "${seclists}/share/wordlists/seclists";

  packages = [
    (python3.withPackages (
      p: with p; [
        numpy
        pillow
        (pwntools.override { inherit debugger; })
        pycryptodome
        impacket
      ]
    ))

    binutils
    binwalk
    strace
    ltrace
    debugger
    rp
    radare2
    ghidra-bin
    burpsuite
    openvpn
    ropium
    metasploit
    hashcat
    john
    stegseek
    ffuf
    nmap
    netexec
    exploitdb
    avalonia-ilspy
    sliver
    wireshark
    bloodhound-py
    evil-winrm
  ] ++ scripts;
}
