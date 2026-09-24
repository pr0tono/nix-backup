{ pkgs, ...} : {
  programs.vim = {
    plugins = with pkgs.vimPlugins; [ 
      auto-pairs 
      catppuccin-vim 
      fzf-vim
      vim-airline 
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
      set termguicolors
      set wildmenu
      syntax enable
      map <F4> :FZF<CR>
      let &t_SI = "\e[6 q"
      let &t_EI = "\e[2 q"
      let g:asyncomplete_auto_popup = 1
    '';
  };
}
