# Моя декларативная NixOS конфигурация

Репозиторий содержит полную конфигурацию для развертывания чистой операционной системы NixOS с графической средой Sway, терминалом Alacritty, шеллом Zsh и предустановленным окружением для Go-разработки.

## Структура репозитория
* `flake.nix` — точка входа для Nix Flakes.
* `configuration.nix` — системные настройки (пользователи, Docker, nix-ld, шрифты).
* `desktop-apps.nix` — пользовательский софт (Telegram, Discord, Brave, Steam и мультимедиа).
* `disk-config.nix` — декларативная разметка дисков через `disko`.

---

## Пошаговое руководство по установке системы с нуля

Загрузитесь с официального **NixOS Minimal ISO** образца. Убедитесь, что интернет подключен, и выполните следующие команды:

### Шаг 1. Переход в root и запуск Git
```bash
# Переходим в режим суперпользователя
sudo su
# Запускаем временную оболочку с установленным git
nix-shell -p git
```

# Клонируем этот репозиторий во временную директорию
```bash
git clone [https://github.com/VladMallory/nix-config](https://github.com/VladMallory/nix-config) /tmp/nix-config
```

# Переходим в папку с конфигами
```bash
cd /tmp/nix-config
```

Разметка диска
```bash
nix run github:nix-community/disko -- --mode zap_create_mount ./disk-config.nix
```

# Генерируем hardware-configuration.nix без перезаписи файловых систем
```bash
nixos-generate-config --no-filesystems --root /mnt
```

# Копируем сгенерированный файл к остальным конфигам
```bash
cp /mnt/etc/nixos/hardware-configuration.nix .
```

# СВЕРХВАЖНО: добавляем файл в Git
```bash
git add hardware-configuration.nix
```

Шаг 5. Запуск установки системы
```bash
nixos-install --root /mnt --flake .#nixos-dev
```

```bash
reboot
```


Первая настройка после перезагрузки
Войдите в систему под своим пользователем:

Логин: vladislav

Пароль: changeme

Сразу же измените дефолтный пароль пользователя на безопасный:

```bash
passwd
```

```bash

sway
```

astronvim

```bash
git clone --depth 1 -b v3.43.1 [https://github.com/AstroNvim/AstroNvim](https://github.com/AstroNvim/AstroNvim) ~/.config/nvim && git clone [https://github.com/VladMallory/for_oneself.git](https://github.com/VladMallory/for_oneself.git) ~/for_oneself && ln -s ~/for_oneself/astronvim/v3 ~/.config/nvim/lua/user
```
