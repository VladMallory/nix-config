{ config
, pkgs
, inputs
, ...
}: {
  imports = [
    ../shared/cache.nix
    ../shared/packages.nix
    ./disk-config.nix
    ./desktop-apps.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-dev";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Vladivostok";
  i18n.defaultLocale = "ru_RU.UTF-8";

  virtualisation.docker.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    openssl
    curl
  ];

  programs.zsh.enable = true;

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      waybar
      alacritty
      rofi
    ];
  };

  services.getty.autologinUser = "vladislav";

  users.users.vladislav = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    initialPassword = "changeme";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };

    users.vladislav = {
      imports = [
        ../shared/home.nix
        ./home.nix
      ];
    };
  };

  system.stateVersion = "24.11";
}
