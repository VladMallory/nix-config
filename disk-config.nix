{
  disko.devices = {
    disk = {
      my-disk = {
        type = "disk";
        device = "/dev/nvme0n1"; # Стандартное имя диска внутри виртуалки UTM
        content = {
          type = "gpt";
          partitions = {
            # Системный раздел загрузчика UEFI
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            # Основной раздел под систему
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };

  # Декларативный Swap-файл на 10 Гигабайт виртуальной оперативной памяти
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 10 * 1024; # Размер в мегабайтах
    }
  ];
}
