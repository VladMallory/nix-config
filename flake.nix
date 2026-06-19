{
  description = "Vladislav's NixOS Dev Environment Flake";

  inputs = {
    # Используем нестабильную ветку для самых свежих версий Go, gopls и т.д.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Модуль декларативной разметки дисков
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Управление пользовательскими конфигами (dotfiles)
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Ваш личный репозиторий с конфигурациями Sway/Waybar
    dotfiles = {
      url = "github:VladMallory/for_oneself";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , disko
    , home-manager
    , ...
    } @ inputs: {
      nixosConfigurations.nixos-dev = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./configuration.nix
        ];
      };
    };
}
