#!/bin/bash
if playerctl status &>/dev/null; then
  status=$(playerctl status 2>/dev/null)
  artist=$(playerctl metadata artist 2>/dev/null)
  title=$(playerctl metadata title 2>/dev/null)

  if [ "$status" = "Playing" ]; then
    icon="󰐊"
  else
    icon="󰏤"
  fi

  text="${icon} ${artist} - ${title}"
  # truncate if too long
  if [ ${#text} -gt 50 ]; then
    text="${text:0:47}..."
  fi

  echo "{\"text\": \"$text\", \"tooltip\": \"$artist - $title\", \"class\": \"$status\"}"
else
  echo "{\"text\": \"\", \"tooltip\": \"Nothing playing\"}"
fi
