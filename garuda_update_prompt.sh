#!/bin/bash

# Check if Zenity is installed, and install it if missing
if ! command -v zenity &> /dev/null; then
  echo "Zenity is not installed. Installing Zenity..."
  sudo pacman -S zenity --noconfirm

  # Confirm Zenity installation
  if ! command -v zenity &> /dev/null; then
    echo "Failed to install Zenity. Please install it manually and try again."
    exit 1
  fi
fi

# Prompt the user for update
zenity --question --title="Garuda Update" --text="Do you want to update Garuda Linux now?" --width=300

# Run the update command if the user agrees
if [ $? -eq 0 ]; then
  konsole -e garuda-update
fi
