#!/usr/bin/env bash
set -e

nix-shell -p git --run "git clone https://github.com/VladMallory/nix-config /tmp/nix-config"

cd /tmp/nix-config

SUBSTITUTERS="https://cache.nixos.org https://mirror.sjtu.edu.cn/nix-channels/store https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"

nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko --option substituters "$SUBSTITUTERS" -- --mode disko ./linux/disk-config.nix || true

ROOT_PART=$(lsblk -l -p -o name,partlabel | grep "disk-my-disk-root$" | awk '{print $1}')
ESP_PART=$(lsblk -l -p -o name,partlabel | grep "disk-my-disk-ESP$" | awk '{print $1}')

if ! mountpoint -q /mnt; then
  echo "Монтирую вручную..."
  if ! mount "$ROOT_PART" /mnt 2>/dev/null; then
    echo "ФС повреждена, чиним..."
    fsck.ext4 -y "$ROOT_PART" || mkfs.ext4 -F "$ROOT_PART"
    mount "$ROOT_PART" /mnt
  fi
fi

mkdir -p /mnt/boot
if ! mountpoint -q /mnt/boot; then
  mount "$ESP_PART" /mnt/boot 2>/dev/null || true
fi

dd if=/dev/zero of=/mnt/.swapfile bs=1M count=8192 2>/dev/null || true
chmod 600 /mnt/.swapfile 2>/dev/null || true
mkswap /mnt/.swapfile 2>/dev/null || true
swapon /mnt/.swapfile 2>/dev/null || true

nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix .
nix-shell -p git --run "git add hardware-configuration.nix"
nixos-install --root /mnt --flake .#nixos-dev --option substituters "$SUBSTITUTERS" --option connect-timeout 5
