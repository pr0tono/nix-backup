{ pkgs, ...} : { # programming languages thingy idk
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






