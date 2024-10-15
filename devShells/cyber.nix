{
  lib,
  mkShell,
  stdenv,
  burpsuite,
  binaryninja,
  binutils,
  binwalk,
  strace,
  ltrace,
  openvpn,
  metasploit,
  gdb,
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
  bloodhound,
  bloodhound-py,
  evil-winrm,
}:

let
  inherit (lib) fileContents makeLibraryPath;

  scripts = [
    (writeShellScriptBin ".q" ''
      "$@" & disown
    '')

    (writeShellScriptBin ".bn" ''
      binaryninja "$@" & disown
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
        pwntools
        pycryptodome
        impacket
      ]
    ))

    binutils
    binwalk
    strace
    ltrace
    gdb
    rp
    radare2
    ghidra-bin
    binaryninja
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
    bloodhound
    bloodhound-py
    evil-winrm
  ] ++ scripts;
}
