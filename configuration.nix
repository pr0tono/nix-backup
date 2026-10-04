{ pkgs, millennium, ... }: { # i love nixos
  imports = [
    ./hardware-configuration.nix
    ./modules/services.nix 
    ./modules/fonts.nix
    ./modules/nix-ld.nix
  ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 1;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        theme = pkgs.catppuccin-grub;
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "8250.nr_uarts=0" ];
    kernel.sysctl."vm.swappiness" = 10;
  };

  networking = {
    hostName = "vivobook-16";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    networkmanager.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [ 22 80 443 25565 ];
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
      allowedUDPPorts = [ 25565 ];
      allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
      allowPing = false;
    };
  };

  time.timeZone = "Europe/Warsaw";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pl_PL.UTF-8";
      LC_IDENTIFICATION = "pl_PL.UTF-8";
      LC_MEASUREMENT = "pl_PL.UTF-8";
      LC_MONETARY = "pl_PL.UTF-8";
      LC_NAME = "pl_PL.UTF-8";
      LC_NUMERIC = "pl_PL.UTF-8";
      LC_PAPER = "pl_PL.UTF-8";
      LC_TELEPHONE = "pl_PL.UTF-8";
      LC_TIME = "pl_PL.UTF-8";
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [{
        users = [ "protono" ];
        keepEnv = true;
        persist = true;
     }];
   };
 };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
      settings.General.Policy = "auto";
    };
  };

  programs = {
    sway.enable = true;
    zsh.enable = true;
    git.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
    steam = {
      enable = true;
      package = pkgs.millennium-steam;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
    wlr.settings.screencast = {
      output_name = "";
      chooser_type = "simple";
      chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
    };
  };

  virtualisation = {
    waydroid.enable = true;
    waydroid.package = pkgs.waydroid-nftables;
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly"; 
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ millennium.overlays.default ];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 35;
  };

  users.users.protono = {
    isNormalUser = true;
    description = "protono";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "kvm"
      "adbusers"
    ];
  };

   system.stateVersion = "26.05";
 }
