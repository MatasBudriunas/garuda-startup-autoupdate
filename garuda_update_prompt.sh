#!/bin/bash

# Log file for errors only
LOGFILE="$HOME/.logs/garuda_update.log"
mkdir -p "$HOME/.logs"

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$LOGFILE"
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] LOG: $1" >> "$LOGFILE"
}

isZenityInstalled() {
    command -v zenity &> /dev/null
}

showUpdatePrompt() {
    zenity --question \
        --title="Garuda Update Manager" \
        --text="Do you want to update Garuda Linux now?" \
        --width=300 2>/dev/null
}

askPassword() {
    zenity --password --title="Authentication Required" 2>/dev/null
}

validatePassword() {
    echo "$1" | sudo -S true 2>/dev/null
}

runParuWithProgress() {
    (
        echo "10"
        echo "# Initializing update..."
        
        echo "$PASSWORD" | sudo -S paru -Syu --noconfirm 2>&1 | {
            while IFS= read -r line; do
                [[ "$line" =~ (error|failed) ]] && log_error "$line"
                
                case "$line" in
                    *"downloading"*) echo "40"; echo "# Downloading packages...";;
                    *"building"*) echo "60"; echo "# Building packages...";;
                    *"installing"*) echo "80"; echo "# Installing updates...";;
                    *"finished"*) echo "100"; echo "# Update completed!";;
                esac
            done
        }
        
        echo "100"
        echo "# Finished!"
    ) | zenity --progress \
        --title="Updating Garuda Linux" \
        --text="Preparing update..." \
        --percentage=0 \
        --width=400 \
        --auto-close \
        --auto-kill 2>/dev/null
}

runCleanup() {
    (
        echo "20"
        echo "# Cleaning old package cache..."
        
        echo "$PASSWORD" | sudo -S paru -Sc --noconfirm 2>&1 | {
            while IFS= read -r line; do
                [[ "$line" =~ (error|failed) ]] && log_error "Cleanup: $line"
            done
        }
        
        echo "100"
        echo "# Cleanup complete."
    ) | zenity --progress \
        --title="System Cleanup" \
        --text="Removing old cached packages..." \
        --percentage=0 \
        --width=400 \
        --auto-close \
        --auto-kill 2>/dev/null
}

runUpdateIfAgreed() {
    
    PASSWORD=$(askPassword)
    
    if [ -z "$PASSWORD" ]; then
        zenity --error --text="No password entered. Update cancelled." 2>/dev/null
        log_error "Update cancelled: No password entered."
        return 1
    fi
    
    if ! validatePassword "$PASSWORD"; then
        zenity --error --text="Incorrect password. Update aborted." 2>/dev/null
        log_error "Invalid password."
        return 1
    fi
    
    runParuWithProgress || {
        zenity --error --text="Update failed. See log file." 2>/dev/null
        log_error "paru update failed."
        return 1
    }
    
    runCleanup

    zenity --info --text="Garuda update and cleanup completed successfully!" 2>/dev/null
}

# MAIN FLOW
exitIfZenityNotInstalled() {
    if ! isZenityInstalled; then
        echo "Zenity not installed. Install it first."
        log_error "Zenity missing. Script cannot run."
        exit 1
    fi
}

exitIfZenityNotInstalled
showUpdatePrompt && runUpdateIfAgreed