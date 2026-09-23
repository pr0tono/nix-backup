{ pkgs, lib, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;

    languagePacks = [ "en-US" ];

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      Cookies = {
        Allow = [
          "https://github.com"
          "https://accounts.google.com"
          "https://youtube.com"
          "https://twitch.tv"
          "https://proton.me"
          "https://anidb.app"
          "https://messenger.com"
          "https:/facebook.com"
        ];
      };

      Preferences = {
        "cookiebanners.service.mode" = 2;
        "cookiebanners.service.mode.privateBrowsing" = 2;
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

          "{5b78178f-135d-4df2-821f-1f289be7f348}" = {
            install_url = moz "catppuccin-mocha-rosewater-git";
            installation_mode = "force_installed";
          };

          "{b9db16a4-6edc-47ec-a1f4-b86292ed211d}" = {
            install_url = moz "video-downloadhelper";
            installation_mode = "force_installed";
          };
          "deArrow@ajay.app" = {
            install_url = moz "dearrow";
            installation_mode = "force_installed";
          };
        };
    };

    profiles.default = {
      settings = {
        "browser.toolbars.bookmarks.visibility" = "never";
        "pdfjs.enableAltText" = false;
        "sidebar.revamp" = false;
        "sidebar.visibility" = "hide-sidebar";
      };
    };
  };
}
