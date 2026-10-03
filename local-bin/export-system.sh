#!/usr/bin/env bash
DOTFILES="$HOME/dotfiles"
mkdir -p "$DOTFILES"

echo "==> Exporting official package list..."
pacman -Qqen >"$DOTFILES/pkglist.txt"

echo "==> Exporting AUR package list..."
pacman -Qqem >"$DOTFILES/aurlist.txt"

echo "==> Copying configs..."
mkdir -p "$DOTFILES/config"
for dir in hypr waybar rofi kitty nvim dunst; do
  [ -d "$HOME/.config/$dir" ] && cp -r "$HOME/.config/$dir" "$DOTFILES/config/"
done

echo "==> Copying scripts..."
mkdir -p "$DOTFILES/local-bin"
cp -r "$HOME/.local/bin/." "$DOTFILES/local-bin/"

echo "==> Copying system config files..."
mkdir -p "$DOTFILES/etc"
sudo cp /etc/timeshift/timeshift.json "$DOTFILES/etc/" 2>/dev/null

echo "==> Done. Snapshot saved to $DOTFILES"
echo "    Now: cd $DOTFILES && git init && git add . && git commit -m 'snapshot'"
echo "    Push it to a remote so it survives a full wipe."
