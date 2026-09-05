{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      add_newline = false;
      format = "$directory$character";
      right_format = "$time";
      directory = {
        style = "gray";
        truncation_length = 1;
        home_symbol = "~";
      };
      time = {
          time_format = "%R";
          style = "dimmed white";
          format = "[$time]($style)";
      };
      character = {
          success_symbol = "[](bold white)";
          error_symbol = "[](bold red)";
          vicmd_symbol = "[](bold yellow)";
       };
    };
  };
}
