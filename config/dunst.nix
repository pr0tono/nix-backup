{ config, pkgs, ... }: {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        indicate_hidden = "yes";
        shrink = "no";
        transparency = 0;
        separator_height = 2;
        padding = 12;
        horizontal_padding = 15;
        font = "monospace 10";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\n%b";
        alignment = "left";
        word_wrap = "yes";
        stack_duplicates = true;
        hide_duplicate_count = true; 
      };

      urgency_low = {
        timeout = 3;
        background = "#1e1e2e";
        foreground = "#6c7086";
        frame_color = "#585b70";
      };

      urgency_normal = {
        timeout = 7;
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#f5e0dc";
      };

      urgency_critical = {
        timeout = 15;
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#585b70";
      };
    };
  };
}   
