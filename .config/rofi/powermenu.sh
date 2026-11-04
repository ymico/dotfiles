#!/usr/bin/env bash

# System Uptime
uptime_str=$(uptime -p | sed 's/up //')

# Options (Clean uniform Material Design icons)
shutdown='󰐥'
reboot='󰑓'
suspend='󰤄'
logout='󰍃'

rofi_cmd() {
    rofi -dmenu \
        -theme ~/.config/rofi/powermenu.rasi \
        -p "  UPTIME: ${uptime_str^^}"
}

run_rofi() {
    echo -e "$shutdown\n$reboot\n$suspend\n$logout" | rofi_cmd
}

chosen="$(run_rofi)"
case "${chosen}" in
    *"$shutdown"*)
        systemctl poweroff
        ;;
    *"$reboot"*)
        systemctl reboot
        ;;
    *"$suspend"*)
        systemctl suspend
        ;;
    *"$logout"*)
        hyprctl dispatch exit
        ;;
esac
