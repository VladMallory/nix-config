# Установка

Перед установкой проверь `linux/disk-config.nix` — диск по умолчанию `/dev/nvme0n1`. Если у тебя другой, замени.

## Автоматически
```bash
curl -L https://raw.githubusercontent.com/VladMallory/nix-config/main/install.sh | sudo bash
```

## Вручную
```bash
sudo su
nix-shell -p git --run "git clone https://github.com/VladMallory/nix-config /tmp/nix-config"
cd /tmp/nix-config
nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode zap_create_mount ./linux/disk-config.nix
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix .
nix-shell -p git --run "git add hardware-configuration.nix"
nixos-install --root /mnt --flake .#nixos-dev
reboot
```

## После перезагрузки
Логин: `vladislav`, пароль: `changeme`

```bash
passwd
sway
git clone --depth 1 -b v3.43.1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
git clone https://github.com/VladMallory/for_oneself.git ~/for_oneself
ln -s ~/for_oneself/astronvim/v3 ~/.config/nvim/lua/user
```
