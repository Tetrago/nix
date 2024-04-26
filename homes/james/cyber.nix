{ pkgs, ... }:

{
  home = {
    file = {
      ".config/pwn.conf".text = ''
        [context]
        terminal=['kitty', 'sh', '-c']
        arch='amd64'
        os='linux'
        endian='little'
        bits=64
      '';

      ".gdbinit".text = "source ${pkgs.gef}/share/gef/gef.py";
    };

    packages = with pkgs; [
      ghidra
      sqlmap
      stegseek
      (python3.withPackages (p: with p; [
        pwntools
        impacket
      ]))
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
      gdb
      rp
      burpsuite
    ];

    shellAliases = {
      "rp++" = "rp++ --colors";
    };
  };
}