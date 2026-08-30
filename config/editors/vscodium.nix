 { pkgs, ... }: {
  programs.vscodium = {
  enable = true;
  package = pkgs.vscodium;
  profiles.default.extensions = with pkgs.vscode-extensions; [
    catppuccin.catppuccin-vsc
    catppuccin.catppuccin-vsc-icons
    ms-python.python
    ms-vscode.makefile-tools
    prettier.prettier-vscode
    twxs.cmake
    usernamehw.errorlens
    oracle.oracle-java
    vscodevim.vim
  ];
 };  
}
