{ pkgs, lib, ... }:

let
  moz = name:
    "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";

  ublockExternalLists = [
    "https://gitlab.com/DandelionSprout/adfilt/-/raw/master/LegitimateURLShortener.txt"
    "https://raw.githubusercontent.com/yokoffing/filterlists/main/block_third_party_fonts.txt"
    "https://raw.githubusercontent.com/yokoffing/filterlists/main/click2load.txt"
    "https://badblock.celenity.dev/abp/unsafe.txt"
    "https://gitlab.com/DandelionSprout/adfilt/-/raw/master/Dandelion%20Sprout's%20Anti-Malware%20List.txt"
    "https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/adblock/dyndns.txt"
    "https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/adblock/tif.mini.txt"
    "https://raw.githubusercontent.com/fmhy/FMHYFilterlist/main/filterlist-basic.txt"
    "https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/adblock/ultimate.mini.txt"
    "https://badblock.celenity.dev/abp/badblock.txt"
    "https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/adblock/spam-tlds-ublock.txt"
    "https://big.oisd.nl"
  ];

  ublockMyFilters = ''
    xn--*
    xn--*$doc,popup,frame

    ||doubleclick.net^$important
    ||google-analytics.com^$important

    ||facebook.com^$important,third-party
    ||facebook.net^$important,third-party
    ||linkedin.com^$important,third-party
    ||instagram.com^$important,third-party
    ||tiktok.com^$important,third-party
    ||twitter.com^$third-party
    ||x.com^$third-party

    ||gravatar.com^$important,third-party

    ||accounts.google.com^$third-party
    ||appleid.apple.com^$third-party
    ||appleid.cdn-apple.com^$third-party

    @@||accounts.google.com^$domain=youtube.com|chromium.org|gstatic.com|googleusercontent.com
    @@||appleid.apple.com^$domain=appleid.cdn-apple.com

    ||challenges.cloudflare.com^$third-party
    @@||challenges.cloudflare.com/cdn-cgi/challenge-platform/$third-party,script,frame

    ||www.google.com^$third-party,subdocument
    @@||www.google.com/recaptcha/$third-party,subdocument

    ||www.gstatic.com^$third-party,script
    @@||www.gstatic.com/recaptcha/$third-party,script

    www.reddit.com###redesign-beta-optin-btn
    old.reddit.com###redesign-beta-optin-btn
  '';

  ublockMyRules = ''
    * * 3p block
    * * 3p-frame block
    * * 3p-script block

    * challenges.cloudflare.com * noop
    * www.google.com * noop
    * www.gstatic.com * noop

    x.com twitter.com * noop
    twitter.com x.com * noop
  '';
in
{
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
          "https://facebook.com"
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

      ExtensionSettings = {
        "*" = {
          installation_mode = "blocked";
        };

        "uBlock0@raymondhill.net" = {
          install_url = moz "ublock-origin";
          installation_mode = "force_installed";
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

      "3rdparty".Extensions."uBlock0@raymondhill.net".adminSettings = {
        userSettings = {
          advancedUserEnabled = true;
          cloudStorageEnabled = false;
        };

        selectedFilterLists = [
          "ublock-filters"
          "ublock-badware"
          "ublock-privacy"
          "ublock-unbreak"
          "ublock-quick-fixes"

          "easylist"
          "easyprivacy"
          "adguard-mobile-ads"
          "adguard-spyware-url"
          "plowe-0"
          "danpollock-0"

          "urlhaus-1"
          "block-lan"

          "easylist-cookie"
          "easylist-social"
          "easylist-chat"
          "easylist-newsletters"
          "easylist-notifications"
          "easylist-annoyances"
        ];

        importedLists = ublockExternalLists;

        externalLists =
          lib.concatStringsSep "\n" ublockExternalLists;

        userFilters = ublockMyFilters;

        dynamicFilteringString = ublockMyRules;
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
