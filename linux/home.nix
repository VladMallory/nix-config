{ pkgs, lib, inputs, ... }:
let wallpaper = import ../shared/wallpaper.nix; in {
  xdg.configFile = {
    "sway/config".source = "${inputs.dotfiles}/wm/sway/config";
    "waybar/config".source = "${inputs.dotfiles}/wm/waybar/config";
    "waybar/style.css".source = "${inputs.dotfiles}/wm/waybar/style.css";
    "alacritty/alacritty.toml".source = "${inputs.dotfiles}/alacrity/alacrity.toml";
  };

  home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    WALL="$HOME/${wallpaper.path}"
    if [ ! -f "$WALL" ]; then
      echo "=== Скачиваю обои ==="
      ${pkgs.curl}/bin/curl -L -o "$WALL" "${wallpaper.url}"
    fi
    sed -i "s|/home/pc/Documents/wallpaper.jpg|$WALL|" "$HOME/.config/sway/config" 2>/dev/null || true
  '';
}
