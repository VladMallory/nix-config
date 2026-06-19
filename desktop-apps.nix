{ config
, pkgs
, ...
}: {
  environment.systemPackages = with pkgs; [
    discord
    obsidian
    localsend
    brave
    bitwarden-desktop
    element-desktop
    qbittorrent
    flclash
    telegram-desktop
    vlc
    ffmpeg
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Открыть порты для Steam Remote Play
    dedicatedServer.openFirewall = true; # Открыть порты для локальных серверов
  };
}
