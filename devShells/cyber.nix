{
  avalonia-ilspy,
  binutils,
  binwalk,
  bloodhound-py,
  burpsuite,
  evil-winrm,
  exploitdb,
  ffuf,
  ghidra-bin,
  hashcat,
  john,
  lib,
  libseccomp,
  ltrace,
  makeWrapper,
  metasploit,
  mkShell,
  netexec,
  nmap,
  openvpn,
  pwndbg,
  python3,
  radare2,
  rp,
  seclists,
  sliver,
  stdenv,
  stdenvNoCC,
  stegseek,
  strace,
  wireshark,
  writeShellScriptBin,
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

  NIX_LD_LIBRARY_PATH = makeLibraryPath [
    stdenv.cc.cc
    libseccomp
  ];
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
  ]
  ++ scripts;
}
