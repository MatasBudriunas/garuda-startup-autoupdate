#!/bin/bash

echo "Starting installation script..."

isCommandAvailable() {
  echo "Checking if $1 is available..."
  command -v "$1" &> /dev/null
}

installIfMissing() {
  local package="$1"
  echo "Checking for $package..."
  if ! isCommandAvailable "$package"; then
    echo "$package is not installed. Attempting to install $package..."
    sudo pacman -S "$package" --noconfirm

    if ! isCommandAvailable "$package"; then
      echo "ERROR: Failed to install $package. Please install it manually and try again."
      exit 1
    fi
    echo "$package installed successfully."
  else
    echo "$package is already installed."
  fi
}

makeScriptExecutable() {
  echo "Making garuda_update_prompt.sh executable..."
  chmod +x garuda_update_prompt.sh
  echo "garuda_update_prompt.sh is now executable."
}

addToAutostart() {
  AUTOSTART_DIR="$HOME/.config/autostart"
  mkdir -p "$AUTOSTART_DIR"

  AUTOSTART_FILE="$AUTOSTART_DIR/garuda_update_prompt.desktop"

  # Create or overwrite the .desktop entry for autostart
  echo "[Desktop Entry]
Type=Application
Exec=\"$PWD/garuda_update_prompt.sh\"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Garuda Update Prompt
Comment=Prompts the user to update Garuda Linux on startup
Terminal=false" > "$AUTOSTART_FILE"

  # Set executable permissions on the .desktop file
  chmod +x "$AUTOSTART_FILE"

  # Debugging output to verify the .desktop file creation
  echo "Created .desktop entry at $AUTOSTART_FILE with the following content:"
  cat "$AUTOSTART_FILE"
}

testAutostart() {
  echo "Testing if the script runs correctly..."
  "$PWD/garuda_update_prompt.sh"
  echo "If you see this message after the prompt, the test run was successful."
}

echo "Installing necessary packages..."
installIfMissing pacman
installIfMissing zenity

echo "Setting up the update script..."
makeScriptExecutable
addToAutostart
testAutostart

echo "Installation complete! The Garuda Update Prompt script is now set to run on startup."
