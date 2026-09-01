{ pkgs, lib, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;

    languagePacks = [ "en-US" ];

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;

      Preferences = {
        "cookiebanners.service.mode.privateBrowsing" = 2;
        "cookiebanners.service.mode" = 2;
        "privacy.donottrackheader.enabled" = true;
        "privacy.fingerprintingProtection" = true;
        "privacy.resistFingerprinting" = true;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
      };

      ExtensionSettings =
        let
          moz = name:
            "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
        in
        {
          "*" = {
            installation_mode = "blocked";
          };

          "uBlock0@raymondhill.net" = {
            install_url = moz "ublock-origin";
            installation_mode = "force_installed";
            updates_disabled = true;
          };

          "{7aa7c68a-141f-45c9-a1c6-6e7382debbe1}" = {
            install_url = moz "catppuccin-mocha";
            installation_mode = "force_installed";
          };

          "{b9db16a4-6edc-47ec-a1f4-b86292ed211d}" = {
            install_url = moz "video-downloadhelper";
            installation_mode = "force_installed";
          };
        };
    };

    profiles.default = {
      settings = {
        "browser.toolbars.bookmarks.visibility" = "never";
        "font.name.monospace.x-western" = "Maple Mono NF CN";
        "font.name.sans-serif.x-western" = "Maple Mono NF CN";
        "font.name.serif.x-western" = "Maple Mono NF CN";
        "font.size.fixed.x-western" = 12;
        "font.size.variable.x-western" = 12;
        "pdfjs.enableAltText" = false;
        "sidebar.revamp" = false;
        "sidebar.visibility" = "hide-sidebar";
        "browser.uiCustomization.state" = builtins.toJSON {
          placements = {
            "nav-bar" = [
              "back-button"
              "forward-button"
              "stop-reload-button"
              "urlbar-container"
              "downloads-button"
              "unified-extensions-button"
            ];
          };

          dirtyAreaCache = [
            "nav-bar"
          ];

          currentVersion = 20;
          newElementCount = 3;
        };
      };

      search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";

        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "26.05";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

            definedAliases = [ "@np" ];
          };
        };
      };
    };
  };
}
