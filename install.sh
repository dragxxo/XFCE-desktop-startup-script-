#!/data/data/com.termux/files/usr/bin/bash
# Installs everything to start up the desktop
# EXCEPT the Termux:X11 app (APK) and rish/Shizuku (set those up manually)

GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
RESET='\e[0m'

#=========Disclamer============

echo "=========================================================="
echo "                       DISCLAIMER                         "
echo "=========================================================="
echo "This project is experimental and provided AS-IS, without"
echo "warranty of any kind. This script modifies Android system"
echo "settings and Termux packages. Use at your own risk."
echo "The author is not responsible for damage or data loss."
echo "=========================================================="
read -p "Do you accept these terms and wish to proceed? (y/N): " response

if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Installation cancelled by user."
    exit 1
fi

#======choose an version ==========
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VERSIONS_DIR="$SCRIPT_DIR/versions"
LATEST_VERSION="advanced-display-v5.5.3.sh"
echo "  - Available versions:"
ls "$VERSIONS_DIR"
read -r -p "Choose a version (default: latest): " VERSION
VERSION="${VERSION:-$LATEST_VERSION}"
DISPLAY_SCRIPT="$VERSIONS_DIR/$VERSION"
if [ ! -f "$DISPLAY_SCRIPT" ]; then
    echo "  - ${YELLOW}Version '$VERSION' not found. Falling back to latest.${RESET}" >&2
    DISPLAY_SCRIPT="$VERSIONS_DIR/$LATEST_VERSION"
fi
if [ ! -f "$DISPLAY_SCRIPT" ]; then
    echo "${RED}  - ERROR: Latest version not found: $DISPLAY_SCRIPT${RESET}" >&2
    exit 1
fi

#===========installing packages==============

if [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ]; then
    echo -e "${RED}This script must be run inside Termux.${RESET}" >&2
    exit 1
fi

echo -e "${YELLOW}Updating package lists...${RESET}"
pkg update -y && pkg upgrade -y || {
    echo -e "${RED}Update failed. Check your mirror/internet.${RESET}" >&2
    exit 1
}

echo -e "${YELLOW}Enabling x11-repo...${RESET}"
pkg install -y x11-repo || {
    echo -e "${RED}Failed to install x11-repo.${RESET}" >&2
    exit 1
}

PACKAGES=(
    xfce4              # provides xfce4-session (desktop)
    dbus               # provides dbus-launch
    termux-x11-nightly # provides the termux-x11 command (X server)
    virglrenderer-android # provides virgl_test_server_android (GPU accel)
    mesa               # gallium drivers (virpipe / llvmpipe)
    pulseaudio         # audio server
    procps             # pgrep, ps, pkill
    grep
    findutils          # xargs
    coreutils
)

FAILED=()
for entry in "${PACKAGES[@]}"; do
    pkg_name="${entry%% *}"
    echo -e "${YELLOW}Installing ${pkg_name}...${RESET}"
    if ! pkg install -y "$pkg_name"; then
        FAILED+=("$pkg_name")
    fi
done

echo
echo -e "${YELLOW}Checking required commands...${RESET}"
MISSING=0
for cmd in xfce4-session dbus-launch termux-x11 virgl_test_server_android pulseaudio pgrep pkill xargs; do
    if command -v "$cmd" &>/dev/null; then
        echo -e "  ${GREEN}OK${RESET}      $cmd"
    else
        echo -e "  ${RED}MISSING${RESET} $cmd"
        MISSING=1
    fi
done

echo
if [ ${#FAILED[@]} -ne 0 ]; then
    echo -e "${RED}Failed packages: ${FAILED[*]}${RESET}"
fi

if [ "$MISSING" -eq 0 ] && [ ${#FAILED[@]} -eq 0 ]; then
    echo -e "${GREEN}All dependencies installed.${RESET}"
    echo "Still needed manually:"
    echo "  - Termux:X11 app (APK)"
    echo "  - Shizuku + ~/rish (chmod +x ~/rish), or run the script with --disable-shizuku"
else
    echo -e "${RED}Some dependencies are missing. Re-run this script or install them manually.${RESET}"
    exit 1
fi

#=============initialize=============
ln -sfn "$DISPLAY_SCRIPT" "$PREFIX/bin/display"
chmod u+x "$DISPLAY_SCRIPT"
echo "  - Desktop launcher installed."
echo "  - Run your XFCE desktop with: display -s"
echo "  - Run display --help for help"

