#!/usr/bin/env bash
set -e # Остановить скрипт при любой ошибке

# Клонируем конфиг, используя nix-shell для временного доступа к git
nix-shell -p git --run "git clone https://github.com/VladMallory/nix-config /tmp/nix-config"

cd /tmp/nix-config

# Запуск disko
nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode zap_create_mount ./disk-config.nix

# Генерация конфига железа и добавление в git
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix .
nix-shell -p git --run "git add hardware-configuration.nix"

# Финальный запуск установки
nixos-install --root /mnt --flake .#nixos-dev
