#!/bin/bash

isZenityInstalled() {
  command -v zenity &> /dev/null
}

showUpdatePrompt() {
  zenity --question --title="Garuda Update" --text="Do you want to update Garuda Linux and gaming tools now?" --width=300
}

runUpdateIfAgreed() {
  if [ $? -eq 0 ]; then
    konsole -e "garuda-update && winetricks --self-update && yay -Syu lutris dxvk-bin proton-ge-custom-bin --noconfirm && sudo pacman -Syu gamemode mangohud --noconfirm"
  fi
}

exitIfZenityNotInstalled() {
  if ! isZenityInstalled; then
    echo "Zenity is not installed. Please ensure all dependencies are installed by running the installer script."
    exit 1
  fi
}

exitIfZenityNotInstalled
showUpdatePrompt
runUpdateIfAgreed
