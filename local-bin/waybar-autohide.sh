#!/usr/bin/env bash
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

is_waybar_running() {
  pgrep -x waybar >/dev/null
}

update_waybar() {
  active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
  windows=$(hyprctl -j workspaces | jq -r --arg id "$active_ws" \
    '.[] | select(.id == ($id|tonumber)) | .windows')

  if [ "${windows:-0}" -gt 0 ] 2>/dev/null; then
    is_waybar_running && pkill -x waybar
  else
    if ! is_waybar_running; then
      waybar &
      disown
    fi
  fi
}

update_waybar

socat -U - UNIX-CONNECT:"$SOCKET" 2>/dev/null | while read -r line; do
  case "$line" in
  workspace* | activewindow* | openwindow* | closewindow* | movewindow*)
    update_waybar
    ;;
  esac
done
