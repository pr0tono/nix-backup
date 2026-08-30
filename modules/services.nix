{ pkgs, modules, ...}: {
  home-manager.users.protono.services.picom = { # eh
     enable = true;
     settings = {
      vsync = true;
      shadow = true;
      fading = false;
      };
     opacityRules = [
      "75:class_g = 'kitty'"
      "85:class_g = 'Dunst'"
      ];
    };
 services = {
   # ly kinda meh dm (but works!)  
  displayManager.ly = {
    enable = true;
    settings = {
      bigclock = "en";
      use-logind = true;
      animation = "doom";
    };
  };

  libinput = {
    enable = true;
    mouse.accelProfile = "flat";
  };

 #mullvad-vpn = { might try to make ts work later
 #  enable = true;
 #  gui.enable = true;
 #};

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
          matches = [
            {
              "device.name" = "~bluez_card.*";
            }
          ];

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

  xserver = {
    enable = true;
    xkb.layout = "us";
    windowManager.i3.enable = true;
  };
  #printers
  printing = {
   enable = true;
   drivers = with pkgs; [ splix samsung-unified-linux-driver hplip ];
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
    X11Forwarding = true;
    X11UseLocalhost = true;
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
