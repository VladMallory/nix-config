{ config
, pkgs
, inputs
, ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ./desktop-apps.nix
  ];

  # Настройки загрузчика системы
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Сеть и имя машины
  networking.hostName = "nixos-dev";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Vladivostok";
  i18n.defaultLocale = "ru_RU.UTF-8";

  # 1. Включаем Docker-демона
  virtualisation.docker.enable = true;

  # 2. Включаем слой совместимости nix-ld для бинарников извне
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    openssl
    curl
  ];

  # 3. Включаем Zsh на уровне системы
  programs.zsh.enable = true;

  # 4. Включаем графическую среду Sway
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      waybar
      alacritty
      rofi
    ];
  };

  # Автоматический вход в консоль без ввода логина и пароля
  services.getty.autologinUser = "vladislav";

  # Настройка основного пользователя
  users.users.vladislav = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    initialPassword = "changeme";
  };

  environment.systemPackages = with pkgs; [
    make
    git
    curl
    btop
    neovim

    # Go-окружение разработки
    go
    gopls
    gofumpt
    delve
    golangci-lint
  ];

  # Шрифты с иконками для Waybar
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Разрешаем установку конкретной небезопасной версии Electron
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  # Автоматическое управление конфигами и софтом пользователя
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };

    users.vladislav =
      { pkgs
      , lib
      , ...
      }: {
        home.stateVersion = "24.11";

        home.sessionPath = [
          "$HOME/.local/bin"
        ];

        # Синхронизация конфигов из твоего репозитория for_oneself
        xdg.configFile."sway/config".source = "${inputs.dotfiles}/wm/sway/config";
        xdg.configFile."waybar/config".source = "${inputs.dotfiles}/wm/waybar/config";
        xdg.configFile."waybar/style.css".source = "${inputs.dotfiles}/wm/waybar/style.css";
        xdg.configFile."alacritty/alacritty.toml".source = "${inputs.dotfiles}/alacrity/alacrity.toml";

        # Декларативный Zsh
        programs.zsh = {
          enable = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;

          oh-my-zsh = {
            enable = true;
            theme = "robbyrussell";
            plugins = [ "git" ];
          };
        };

        # 🔥 МАГИЯ АВТОУСТАНОВКИ OPENCODE
        home.activation.autoInstallOpenCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -f "$HOME/.local/bin/opencode" ]; then
            echo "=== NixOS автоматически устанавливает OpenCode ==="
            ${pkgs.curl}/bin/curl -fsSL https://opencode.ai/install | ${pkgs.bash}/bin/bash
          else
            echo "=== OpenCode уже установлен, пропускаем ==="
          fi
        '';
      };
  };

  system.stateVersion = "24.11";
}
