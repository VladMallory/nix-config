{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gnumake
    git
    curl
    btop
    unzip
    telegram-desktop
    alacritty
    obsidian
    nixd
    nixpkgs-fmt
  ];
}
