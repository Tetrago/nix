{ ... }:

{
  programs = {
    xfconf.enable = true;
  };

  services = {
    tumbler.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
  };
}
