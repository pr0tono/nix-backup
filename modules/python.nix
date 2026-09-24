{ pkgs, ...}: {
  home.packages = with pkgs; [
    python3
    python314Packages.pip
    python314Packages.requests
    python314Packages.beautifulsoup4
  ];
}
