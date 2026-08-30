{ pkgs, ...}: {
 fonts.packages = with pkgs; [
   dina-font
   fira-code
   fira-code-symbols
   liberation_ttf
   maple-mono.NF-CN
   mplus-outline-fonts.githubRelease
   nerd-fonts.noto
   noto-fonts
   noto-fonts-cjk-sans
   noto-fonts-color-emoji
   proggyfonts
   roboto-mono
  ];
}
