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
  gef,
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
  avalonia-ilspy,
}:

let
  inherit (lib) fileContents makeLibraryPath;
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
    gef
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
  ];
}
