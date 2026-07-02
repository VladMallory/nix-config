{ pkgs, lib, ... }: {
  home.activation.installBrewCasks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -x /opt/homebrew/bin/brew ]; then
      echo "=== Устанавливаю Homebrew ==="
      ${pkgs.bash}/bin/bash -c "$(${pkgs.curl}/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

    apps=(bitwarden docker)
    for app in "''${apps[@]}"; do
      if /opt/homebrew/bin/brew list --cask "$app" &>/dev/null; then
        echo "=== $app уже установлен, пропускаем ==="
      else
        echo "=== Устанавливаю $app через Homebrew ==="
        /opt/homebrew/bin/brew install --cask "$app"
      fi
    done
  '';
}
