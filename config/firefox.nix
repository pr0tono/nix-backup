{ pkgs, lib, ... }: {
  programs.firefox = {
    enable = true;

    languagePacks = [ "en-US" ];

    policies = {
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;

      DisableBuiltinPDFViewer = true;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxScreenshots = true;
      DisableForgetButton = true;
      DisableMasterPasswordCreation = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisableSetDesktopBackground = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFormHistory = true;
      DisablePasswordReveal = true;

      BlockAboutConfig = false;
      BlockAboutProfiles = true;
      BlockAboutSupport = true;

      DisplayMenuBar = "never";
      DontCheckDefaultBrowser = true;
      HardwareAcceleration = false;
      OfferToSaveLogins = false;
      DefaultDownloadDirectory = "~/Downloads";

      ExtensionSettings = let
        moz = name:
          "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
      in {
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

      "3rdparty".Extensions."uBlock0@raymondhill.net".adminSettings = {
        userSettings = rec {
          uiTheme = "dark";
          uiAccentCustom = true;
          uiAccentCustom0 = "#dc8a78";
          cloudStorageEnabled = false;
        };

        selectedFilterLists = [
          "ublock-filters"
          "ublock-badware"
          "ublock-privacy"
          "ublock-quick-fixes"
          "ublock-unbreak"
          "easylist"
          "easyprivacy"
          "plowe-0"
          "adguard-annoyance"
          "adguard-social"
          "urlhaus-1"
          "POL-0"
        ];
      };
    };

    profiles.default = {
      settings = {
        "browser.ai.control.default" = "blocked";
        "browser.ai.control.linkPreviewKeyPoints" = "blocked";
        "browser.ai.control.pdfjsAltText" = "blocked";
        "browser.ai.control.sidebarChatbot" = "blocked";
        "browser.ai.control.smartTabGroups" = "blocked";
        "browser.ai.control.translations" = "blocked";
        "browser.ml.enable" = false;
        "browser.ml.chat.enabled" = false;
        "browser.ml.chat.menu" = false;
        "browser.ml.linkPreview.enabled" = false;
        "extensions.ml.enabled" = false;
        "pdfjs.enableAltText" = false;
        "font.name.sans-serif.x-western" = "Maple Mono NF CN";
        "font.name.serif.x-western" = "Maple Mono NF CN";
        "font.name.monospace.x-western" = "Maple Mono NF CN";
        "font.size.variable.x-western" = 12;
        "font.size.fixed.x-western" = 12;
        "sidebar.revamp" = false;
        "sidebar.visibility" = "hide-sidebar";
        "layout.css.prefers-color-scheme.content-override" = 0;
        "browser.toolbars.bookmarks.visibility" = "never";
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
                  { name = "channel"; value = "26.2"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
        };
      };
    };
  };
}
