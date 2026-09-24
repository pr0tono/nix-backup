{ pkgs, ...} : {
  home.packages = with pkgs; [
    bison
    bun
    cargo
    cmake
    dotnet-sdk
    elixir
    flex
    gcc
    ghc
    gnumake
    go
    godot
    gradle
    kotlin
    lua
    meson
    nil
    nim
    ninja
    nodejs
    openjdk25
    perl
    php
    R
    ruby
    ruff
    shellcheck
    statix
    swift
    typescript
    yarn
  ];
}






