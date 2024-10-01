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
}:

let
  inherit (lib) fileContents makeLibraryPath;

  q = writeShellScriptBin "q" ''
    "$@" & disown
  '';

  q-bn = writeShellScriptBin "q.bn" ''
    binaryninja "$@" & disown
  '';

  q-bs = writeShellScriptBin "q.bs" ''
    burpsuite "$@" & disown
  '';

  q-script = writeShellScriptBin "q.s" ''
    cat <<EOF > exploit.py
    #!/usr/bin/env python3

    from pwn import *

    elf = ELF("$1")

    io = elf.process()

    io.interactive()
    EOF

    chmod +x exploit.py
  '';
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
        pycrypto
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
    q
    q-bn
    q-bs
    q-script
  ];
}
