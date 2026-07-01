{ config
, pkgs
, inputs
, ...
}: {
  imports = [
    ../shared/cache.nix
    ../shared/packages.nix
    ./packages.nix
  ];

  system.primaryUser = "vlad";
  system.defaults.dock.autohide = false;

  system.defaults.CustomUserPreferences = {
    "com.apple.dock" = {
      "autohide-time-modifier" = 0;
      "wvous-tl-corner" = 0;
      "wvous-tr-corner" = 0;
      "wvous-bl-corner" = 0;
      "wvous-br-corner" = 0;
    };
    "NSGlobalDomain" = {
      "NSAutomaticWindowAnimationsEnabled" = false;
    };
    "com.apple.assistant.support" = {
      "Assistant Enabled" = false;
    };
    "com.apple.assistant.backedup" = {
      "Assistant Enabled" = false;
    };
    "com.apple.Siri" = {
      "StatusMenuVisible" = false;
      "UserHasDeclinedEnable" = true;
    };
  };

  system.activationScripts.disableSpotlight.text = ''
    mdutil -a -i off 2>/dev/null || true
  '';

  networking.hostName = "vlad-mac";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };

    users.vlad = {
      imports = [
        ../shared/home.nix
        ./home.nix
      ];
    };
  };

  system.stateVersion = 5;
}
