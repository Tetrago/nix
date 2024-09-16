{
  lib,
  mkShell,
  stdenv,
  sqlmap,
  stegseek,
  ffuf,
  nmap,
  netexec,
  metasploit,
  seclists,
  exploitdb,
  hashcat,
  john,
  file,
  binutils,
  binwalk,
  strace,
  ltrace,
  openvpn,
  gdb,
  rp,
  radare2,
  python3,
}:

let
  inherit (lib) fileContents makeLibraryPath;
in
mkShell {
  name = "cyber";

  NIX_LD_LIBRARY_PATH = makeLibraryPath [ stdenv.cc.cc ];
  NIX_LD = fileContents "${stdenv.cc}/nix-support/dynamic-linker";

  packages = [
    (python3.withPackages (
      p: with p; [
        numpy
        pillow
        pwntools
        impacket
      ]
    ))

    sqlmap
    stegseek
    ffuf
    nmap
    netexec
    metasploit
    seclists
    exploitdb
    hashcat
    john
    file
    binutils
    binwalk
    strace
    ltrace
    openvpn
    gdb
    rp
    radare2
  ];
}
