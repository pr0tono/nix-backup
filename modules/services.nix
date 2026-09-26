{ pkgs, modules, ...}: {
  services = {
    displayManager = {
      sessionPackages = [ pkgs.sway ];
      defaultSession = "sway"; 
      ly = {
        enable = true;
        settings = {
          bigclock = "en";
          use-logind = true;
          animation = "colormix";
          colormix_col1 = "0xFFFFA500";
        };
      };
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      wireplumber = {
        enable = true;
        extraConfig."51-bluetooth-autoswitch" = {
          "monitor.bluez.rules" = [
            {
              matches = [{ "device.name" = "~bluez_card.*"; }];
              actions = {
                update-props = {
                  "priority.driver" = 2000;
                  "priority.session" = 2000;
                };
              };
            }
          ];
        };
      };
    };

    #printers
    printing = {
      enable = true;
      drivers = with pkgs; [ splix hplip ];
    };
    ipp-usb.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
   
    openssh = {
      enable = true;
      settings = {
    };
  };

    # random shit ngl
    flatpak.enable = true;
    blueman.enable = true;
    ollama.enable = true;
    tailscale.enable = true;
    udisks2.enable = true;
    fwupd.enable = true;
    tor.enable = true;
    fstrim.enable = true;
    thermald.enable = true;
    power-profiles-daemon.enable = true;
  };
}
