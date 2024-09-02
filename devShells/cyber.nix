{ pkgs }:

pkgs.mkShell {
  name = "cyber";

  packages = with pkgs; [
    ghidra
    burpsuite

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
