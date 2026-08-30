{ pkgs, ...}: {
  home.packages = with pkgs; [
    python3
    python313Packages.pip
    python313Packages.requests
    python313Packages.beautifulsoup4
  ];
}
