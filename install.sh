#!/usr/bin/env bash
set -e # Остановить скрипт при любой ошибке

# Клонируем конфиг, используя nix-shell для временного доступа к git
nix-shell -p git --run "git clone https://github.com/VladMallory/nix-config /tmp/nix-config"

#!/usr/bin/env bash
set -e
cd /tmp/nix-config
# 1. Разметка диска через disko
nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode zap_create_mount ./disk-config.nix

dd if=/dev/zero of=/mnt/.swapfile bs=1M count=8192
chmod 600 /mnt/.swapfile
mkswap /mnt/.swapfile
swapon /mnt/.swapfile
echo "SWAP успешно активирован!"
# =========================================================

# 2. Генерация конфига железа
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix .
nix-shell -p git --run "git add hardware-configuration.nix"

# 3. Установка системы (теперь памяти точно хватит)
nixos-install --root /mnt --flake .#nixos-dev
