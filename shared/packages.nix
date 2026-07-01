{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gnumake
    git
    curl
    btop
    neovim
    unzip
    telegram-desktop
    alacritty
    obsidian
    nixd
    nixpkgs-fmt

    go
    gopls
    gofumpt
    delve
    golangci-lint
  ];
}
