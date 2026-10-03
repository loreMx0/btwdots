#!/usr/bin/env bash

THEME="$HOME/.config/rofi/death-stranding.rasi"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
action=$(printf "󰀻  APPS\n󰏖  INSTALL\n󰣇  AUR\n󰆴  UNINSTALL\n󰸉  WALLPAPER\n󰚰  UPDATE" |
  rofi -dmenu -i -p "󰍉 Launcher" -theme "$THEME")

case "$action" in

"󰀻  APPS")
  rofi -show drun -theme "$THEME"
  ;;

"󰏖  INSTALL")
  packages=$(pacman -Slq | sort -u)

  selected=$(printf '%s\n' "$packages" |
    rofi -dmenu -i -matching fuzzy \
      -p "󰏖 Install" -no-custom -theme "$THEME")

  [ -z "$selected" ] && exit 0

  kitty --title "Pacman Install" bash -c "
            sudo pacman -S --needed '$selected'
            echo
            read -rp 'Press Enter to close...'
        "
  ;;

"󰣇  AUR")
  if ! command -v yay &>/dev/null; then
    rofi -e "yay is not installed" -theme "$THEME"
    exit 1
  fi

  packages=$(yay -Slq aur | sort -u)

  selected=$(printf '%s\n' "$packages" |
    rofi -dmenu -i -matching fuzzy \
      -p "󰣇 AUR Install" -no-custom -theme "$THEME")

  [ -z "$selected" ] && exit 0

  kitty --title "AUR Install" bash -c "
            yay -S --needed '$selected'
            echo
            read -rp 'Press Enter to close...'
        "
  ;;

"󰆴  UNINSTALL")
  packages=$(pacman -Qq | sort -u)

  selected=$(printf '%s\n' "$packages" |
    rofi -dmenu -i -matching fuzzy \
      -p "󰆴 Uninstall" -no-custom -theme "$THEME")

  [ -z "$selected" ] && exit 0

  confirm=$(printf "Yes\nNo" |
    rofi -dmenu -i -p "Remove $selected?" -theme "$THEME")

  [ "$confirm" != "Yes" ] && exit 0

  kitty --title "Pacman Uninstall" bash -c "
            sudo pacman -Rns '$selected'
            echo
            read -rp 'Press Enter to close...'
        "
  ;;

"󰸉  WALLPAPER")

  WALL_DIR="$HOME/Pictures/wallpapers"
  STATE_FILE="$HOME/.cache/current_wallpaper"

  selected=$(
    for f in "$WALL_DIR"/*.jpg "$WALL_DIR"/*.jpeg "$WALL_DIR"/*.png; do
      [ -e "$f" ] || continue
      name=$(basename "$f")
      printf '%s\0icon\x1f%s\n' "$name" "$f"
    done | rofi -dmenu -i -p "Wallpaper" -show-icons -theme ~/.config/rofi/wallpaper.rasi
  )

  [ -z "$selected" ] && exit 0

  echo "$WALL_DIR/$selected" >"$STATE_FILE"

  pkill swaybg
  sleep 0.3
  setsid swaybg -i "$WALL_DIR/$selected" -m fill >/tmp/swaybg.log 2>&1 &
  disown
  ;;

"󰚰  UPDATE")
  confirm=$(printf "Yes\nNo" |
    rofi -dmenu -i -p "Run full system update?" -theme "$THEME")

  [ "$confirm" != "Yes" ] && exit 0

  kitty --title "System Update" bash -c "
            ~/.local/bin/system-update.sh
            echo
            read -rp 'Press Enter to close...'
        "
  ;;

esac
