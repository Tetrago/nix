{ lib, pkgs }:

let
  inherit (lib) fileContents makeLibraryPath;
in
pkgs.mkShell {
  name = "cyber";

  NIX_LD_LIBRARY_PATH = makeLibraryPath [ pkgs.stdenv.cc.cc ];
  NIX_LD = fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";

  packages = with pkgs; [
    (python3.withPackages (
      p: with p; [
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
