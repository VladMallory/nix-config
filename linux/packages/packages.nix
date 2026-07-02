{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
