#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing base tools..."
sudo pacman -Syu --needed --noconfirm base-devel git

if ! command -v yay &>/dev/null; then
  echo "==> Installing yay..."
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
fi

echo "==> Installing official packages..."
sudo pacman -S --needed --noconfirm - <"$DOTFILES/pkglist.txt"

echo "==> Installing AUR packages..."
yay -S --needed --noconfirm - <"$DOTFILES/aurlist.txt"

echo "==> Linking configs..."
mkdir -p "$HOME/.config"
for dir in "$DOTFILES/config"/*/; do
  name=$(basename "$dir")
  rm -rf "$HOME/.config/$name"
  ln -s "$dir" "$HOME/.config/$name"
done

echo "==> Linking scripts..."
mkdir -p "$HOME/.local/bin"
cp -r "$DOTFILES/local-bin/." "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/"*

echo "==> Restoring Timeshift config..."
sudo cp "$DOTFILES/etc/timeshift.json" /etc/timeshift/timeshift.json 2>/dev/null || true

echo "==> Enabling services..."
sudo systemctl enable --now sddm
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now rtkit-daemon

echo "==> Done. Reboot and log into Hyprland."
