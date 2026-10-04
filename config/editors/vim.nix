{ pkgs, ...} : {
  programs.vim = {
    plugins = with pkgs.vimPlugins; [ 
      auto-pairs 
      catppuccin-vim 
      lightline-vim
      lightline-ale
      ale
    ];
    enable = true;
    settings = { 
      ignorecase = true; 
      number = true;
      smartcase = true;
    };
    extraConfig = ''
      colorscheme catppuccin
      command! W execute 'w !doas tee % > /dev/null' <bar> edit!
      set background=dark
      set mouse=a
      set nobackup
      set nocompatible
      set cursorline
      set termguicolors
      set wildmenu
      syntax enable
      let &t_SI = "\e[6 q"
      let &t_EI = "\e[2 q"
      let g:lightline = {
      \ 'colorscheme': 'srcery_drk',
      \ }
   '';
 };
}
