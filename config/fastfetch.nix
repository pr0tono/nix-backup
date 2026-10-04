{ ... }: {
  programs.fastfetch = {
    enable = true;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json";

      logo = {
        type = "small";
          color = {
            "1" = "black";
            "2" = "white";
            "3" = "black";
            "4" = "white";
            "5" = "black";
            "6" = "white";
          };
        };

      display = {
        color = {
          keys = "black";
          title = "black";
        };
      };

      modules = [
        "title"
        "os"
        "host"
        "kernel"
        {
          type = "command";
          key = "OS Age";
          text = "echo $(( ( $(date +%s) - $(date -d '2026-08-01' +%s) ) / 86400 )) days";
        }
        {
          type = "memory";
          key = "Memory";
          format = "{used} / {total}";
        }
        {
          type = "disk";
          folders = "/";
          key = "Disk";
          format = "{size-used} / {size-total}";
        }
      ];
    };
  };
}
