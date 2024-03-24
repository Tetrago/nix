{ pkgs }:

pkgs.mkShell {
  name = "cyber";

  nativeBuildInputs = with pkgs; [
    ghidra
    sqlmap
    stegseek
    python311Packages.pwntools
    python311Packages.impacket
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
    radare2
    openvpn
    gef
  ];
}
