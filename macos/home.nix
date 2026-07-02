{ pkgs
, lib
, ...
}:
let
  wallpaper = import ../shared/wallpaper.nix;
in
{
  home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    WALL="$HOME/${wallpaper.path}"
    if [ ! -f "$WALL" ]; then
      echo "=== Скачиваю обои ==="
      ${pkgs.curl}/bin/curl -L -o "$WALL" "${wallpaper.url}"
    fi
    uid=$(id -u vlad)
    launchctl asuser "$uid" sudo -u vlad osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$WALL\"" 2>/dev/null || true
  '';
}
