#!/usr/bin/env bash
set -e

echo "==> Creating Timeshift snapshot..."
sudo timeshift --create --comments "Pre-update snapshot $(date +%Y-%m-%d_%H-%M)" --tags D

echo "==> Updating official repo packages..."
sudo pacman -Syu --noconfirm

echo "==> Updating AUR packages..."
if command -v yay &>/dev/null; then
  yay -Sua --noconfirm
else
  echo "yay not found, skipping AUR update"
fi

echo "==> Updating Flatpak packages (if any)..."
if command -v flatpak &>/dev/null; then
  flatpak update -y
fi

echo "==> Clearing pacman package cache (keeping last 2 versions)..."
sudo pacman -Sc --noconfirm

echo "==> Clearing orphaned packages..."
orphans=$(pacman -Qtdq || true)
if [ -n "$orphans" ]; then
  sudo pacman -Rns $orphans --noconfirm
else
  echo "No orphaned packages to remove."
fi

echo "==> Clearing yay/AUR build cache..."
if command -v yay &>/dev/null; then
  yay -Sc --noconfirm
fi

echo "==> Clearing user cache directory (safe subset)..."
rm -rf "$HOME/.cache/thumbnails"/*
rm -rf "$HOME/.cache/yay"/*

echo "==> Update complete."
