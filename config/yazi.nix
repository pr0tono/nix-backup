{ config, pkgs, ... }: {
  catppuccin.yazi.enable = true;
  programs.yazi = {
    enable = true;
    settings = {
      mgr = {
        show_hidden = true;
        sort_by = "natural";
        ratio = [ 1 2 3 ];
        sort_sensitive = true;
        sort_dir_first = true;
      };
      preview = {
        wrap = "yes";
        max_with = 1500;
        max_height = 1500;
      };
      tasks = {
        image_alloc = 0;
        image_bound = [ 0 0 ];
      };
    };
    plugins = with pkgs.yaziPlugins; {
      git = git;
      chmod = chmod;
      full-border = {
        package = full-border;
        setup = true;
      };
    };
  };
}
