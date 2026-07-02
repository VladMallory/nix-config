{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    neovim
    go
    gopls
    gofumpt
    delve
    golangci-lint
  ];
}
