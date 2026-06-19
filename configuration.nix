{ config
, pkgs
, inputs
, ...
}: {
  imports = [
    ./hardware-configuration.nix # Генерируется автоматически, в Git слать не нужно
    ./disk-config.nix
  ];

  # Настройки загрузчика системы
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Сеть и имя машины
  networking.hostName = "nixos-dev";
  networking.networkmanager.enable = true;

  # Локализация и часовой пояс (Уссурийск)
  time.timeZone = "Asia/Vladivostok";
  i18n.defaultLocale = "ru_RU.UTF-8";

  # 1. Включаем Docker-демона
  virtualisation.docker.enable = true;

  # 2. Включаем ультимативный слой совместимости nix-ld.
  # Он нужен, чтобы запущенный из-под curl скрипта OpenCode понимал файловую систему NixOS
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    openssl
    curl
  ];

  # 3. Включаем графическую среду Sway
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      waybar # Ваша панель статуса
      foot # Легкий и быстрый терминал для Wayland
      dmenu # Программа запуска приложений
    ];
  };

  # Настройка основного пользователя
  users.users.vladislav = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # wheel дает sudo, docker — работу без sudo
    initialPassword = "changeme"; # Смените пароль через `passwd` после первого входа
  };

  # Список системных пакетов
  environment.systemPackages = with pkgs; [
    make
    git
    curl
    btop
    neovim

    # Go-окружение разработки
    go
    gopls
    delve
    golangci-lint
  ];

  # Шрифты с иконками для Waybar
  fonts.packages = with pkgs; [
    nerdfonts
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Автоматическое управление конфигами и софтом пользователя
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };

    # Обрати внимание: добавился аргумент `lib` для работы скриптов активации
    users.vladislav =
      { pkgs
      , lib
      , ...
      }: {
        home.stateVersion = "24.11";

        # Добавляем в PATH пути, куда скрипт OpenCode обычно ставит свои бинарники
        home.sessionPath = [
          "$HOME/.local/bin"
        ];

        # Синхронизация твоих конфигов оконного менеджера из репозитория for_oneself
        xdg.configFile."sway/config".source = "${inputs.dotfiles}/wm/sway/config";
        xdg.configFile."waybar/config".source = "${inputs.dotfiles}/wm/waybar/config";
        xdg.configFile."waybar/style.css".source = "${inputs.dotfiles}/wm/waybar/style.css";

        # 🔥 МАГИЯ АВТОУСТАНОВКИ OPENCODE
        # Этот скрипт выполнится автоматически в самом конце сборки системы Nix-ом
        home.activation.autoInstallOpenCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          # Проверяем, установлена ли уже утилита, чтобы не скачивать её при каждой пересборке
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
