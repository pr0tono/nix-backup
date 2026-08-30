{
  description = "vivobook 16 flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium-nix = {
      url = "github:AlvaroParker/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    millennium = {
      url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:4evy/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };  
    catppuccin-nix = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    helium-nix,
    millennium,
    nixcord,
    spicetify-nix,
    catppuccin-nix,
    ...
  } @ inputs: {
    nixosConfigurations.vivobook-16 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit 
          inputs
          helium-nix 
          millennium 
          nixcord 
          spicetify-nix 
          catppuccin-nix;
      };

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs helium-nix nixcord millennium spicetify-nix catppuccin-nix; };
          home-manager.users.protono = ./home.nix;
        }
      ];
    };
  };
}
