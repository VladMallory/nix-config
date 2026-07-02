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

    shellAliases = {
      n = "nvim";
    };
  };

  home.activation.installGoland = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "=== Устанавливаю GoLand ==="
    export NIXPKGS_ALLOW_UNFREE=1
    ${pkgs.nix}/bin/nix build "nixpkgs#jetbrains.goland" \
      --out-link "$HOME/.local/share/goland" \
      --extra-experimental-features flakes \
      --impure \
      || echo "⚠️  GoLand пропущен (не скачался)"

    if [ "$(uname)" = "Darwin" ] && [ -d "$HOME/.local/share/goland/Applications" ]; then
      app=$(find "$HOME/.local/share/goland/Applications" -name "*.app" -maxdepth 1 | head -n1)
      if [ -n "$app" ]; then
        echo "=== Создаю symlink в /Applications ==="
        sudo ln -sf "$app" /Applications/
      fi
    fi
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
