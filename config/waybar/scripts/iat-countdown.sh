#!/bin/bash
target=$(date -d "2027-06-05" +%s)
today=$(date -d "$(date +%F)" +%s)
days=$(( (target - today) / 86400 ))

echo "{\"text\": \"${days}d to IAT 2027\", \"tooltip\": \"IAT 2027 — 5 June 2027\"}"
