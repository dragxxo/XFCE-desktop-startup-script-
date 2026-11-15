
#!/data/data/com.termux/files/usr/bin/bash

# XFCE Desktop Environment Uninstaller
# Removes packages installed by the desktop installer.
# Preserves essential Termux utilities and user data.

GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
RESET='\e[0m'

clear

echo -e "${RED}"
echo "=========================================================="
echo "                   !!! WARNING !!!"
echo "=========================================================="
echo "This script will REMOVE the XFCE desktop environment."
echo
echo "The following will be removed:"
echo "  - XFCE4 desktop environment"
echo "  - Termux:X11 command package"
echo "  - Mesa / VirGL components"
echo "  - PulseAudio"
echo "  - Desktop-related configuration"
echo "  - Desktop launcher"
echo
echo "Essential utilities will be preserved:"
echo "  - Git"
echo "  - Bash"
echo "  - Coreutils"
echo "  - Grep / Findutils"
echo "  - Other unrelated packages"
echo
echo "User files and unrelated projects will NOT be deleted."
echo
echo "WARNING: This operation cannot be automatically undone."
echo "=========================================================="
echo -e "${RESET}"

if [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ]; then
    echo -e "${RED}This script must run inside Termux.${RESET}"
    exit 1
fi

read -r -p "Are you absolutely sure? (y/N): " response

if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo
echo -e "${YELLOW}Starting uninstallation...${RESET}"

# Only packages explicitly installed by the desktop installer.
# Essential utilities are intentionally excluded.

PACKAGES=(
    xfce4
    dbus
    termux-x11-nightly
    virglrenderer-android
    mesa
    pulseaudio
    x11-repo
)

FAILED=()

for package in "${PACKAGES[@]}"; do

    # Check whether the package is actually installed.
    status=$(dpkg-query -W -f='${Status}' "$package" 2>/dev/null)

    if [[ "$status" == "install ok installed" ]]; then
        echo -e "${YELLOW}Removing $package...${RESET}"

        if ! pkg uninstall -y "$package"; then
            FAILED+=("$package")
        fi
    else
        echo "Skipping $package (not installed)."
    fi

done
# Remove desktop configuration and generated logs.
FILES_TO_REMOVE=(
    "$HOME/.xfce-config"
    "$HOME/virgl.log"
    "$HOME/XFCE.log"
)

for file in "${FILES_TO_REMOVE[@]}"; do
    if [[ -f "$file" ]]; then
        rm -f -- "$file"
        echo "Removed: $file"
    fi
done
# Optional Desktop directory cleanup.
if [[ -d "$HOME/Desktop" ]]; then

    echo
    echo -e "${YELLOW}OPTIONAL CLEANUP${RESET}"
    echo "The following directory exists:"
    echo "  $HOME/Desktop"
    echo
    echo "It may have been created by XFCE or another application."
    echo "Its contents will be permanently deleted if you proceed."

    read -r -p "Delete Desktop directory and ALL its contents? (y/N): " delete_desktop

    if [[ "$delete_desktop" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        rm -rf -- "$HOME/Desktop"
        echo "Desktop directory removed."
    else
        echo "Desktop directory preserved."
    fi
fi
echo
echo "=========================================================="

if [ ${#FAILED[@]} -eq 0 ]; then
    echo -e "${GREEN}Uninstallation completed.${RESET}"
else
    echo -e "${RED}Some packages could not be removed:${RESET}"
    printf '%s\n' "${FAILED[@]}"
fi

echo
echo "Essential Termux utilities were preserved."
echo "No automatic autoremove was performed."
echo "=========================================================="

