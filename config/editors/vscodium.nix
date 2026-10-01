{ pkgs, ... }: {
  programs.vscodium = {
  enable = true;
  package = pkgs.vscodium;
  mutableExtensionsDir = false;
  profiles.default.extensions = with pkgs.vscode-extensions; [
    catppuccin.catppuccin-vsc
    catppuccin.catppuccin-vsc-icons
    docker.docker
    ms-python.python
    ms-vscode-remote.remote-ssh
    ms-vscode.makefile-tools
    oracle.oracle-java
    prettier.prettier-vscode
    twxs.cmake
    usernamehw.errorlens
    redhat.vscode-xml
    redhat.java
    vscodevim.vim
  ];
};  
}
