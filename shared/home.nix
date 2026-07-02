{ pkgs, lib, inputs, ... }: {
  home.stateVersion = "24.11";

  home.homeDirectory = lib.mkIf pkgs.stdenv.isDarwin (lib.mkForce "/Users/vlad");

  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "$HOME/.local/bin"
    "$HOME/.opencode/bin"
    "$HOME/golang/ffmpeg"
  ];

  programs.alacritty = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile "${inputs.dotfiles}/alacrity/alacrity.toml");
  };

  home.sessionVariables.TERM = "xterm-256color";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
  };

  home.activation.installGoland = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "=== Устанавливаю GoLand ==="
    ${pkgs.nix}/bin/nix build "nixpkgs#jetbrains.goland" \
      --out-link "$HOME/.local/share/goland" \
      --extra-experimental-features flakes \
      2>/dev/null || echo "⚠️  GoLand пропущен (не скачался)"
  '';

  home.activation.autoInstallOpenCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.opencode/bin/opencode" ]; then
      echo "=== Nix автоматически устанавливает OpenCode ==="
      export PATH="${pkgs.curl}/bin:${pkgs.unzip}/bin:$PATH"
      ${pkgs.bash}/bin/bash -c "$(${pkgs.curl}/bin/curl -fsSL https://opencode.ai/install)"
    else
      echo "=== OpenCode уже установлен, пропускаем ==="
    fi
  '';
}
