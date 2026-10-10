
#!/data/data/com.termux/files/usr/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo -e "${YELLOW}Updating Termux package repositories...${RESET}"
pkg update

echo -e "${YELLOW}Enabling X11 repository...${RESET}"
pkg install -y x11-repo

echo -e "${YELLOW}Installing CLI utilities...${RESET}"
pkg install -y \
    coreutils \
    findutils \
    grep \
    procps \
    psmisc \
    sed \
    gawk \
    util-linux

echo -e "${YELLOW}Installing Shizuku/Android CLI support...${RESET}"
pkg install -y \
    termux-tools \
    termux-exec

echo -e "${YELLOW}Installing XFCE desktop...${RESET}"
pkg install -y \
    xfce4 \
    xfce4-session \
    xfce4-goodies

echo -e "${YELLOW}Installing D-Bus...${RESET}"
pkg install -y \
    dbus \
    dbus-glib

echo -e "${YELLOW}Installing Termux:X11...${RESET}"
pkg install -y \
    termux-x11-nightly

echo -e "${YELLOW}Installing GPU acceleration stack...${RESET}"
pkg install -y \
    mesa \
    mesa-demos \
    virglrenderer \
    virglrenderer-android \
    vulkan-loader-generic

echo -e "${YELLOW}Installing audio support...${RESET}"
pkg install -y \
    pulseaudio \
    pavucontrol

echo -e "${GREEN}All requested display dependencies installed.${RESET}"

echo
echo "Checking required commands..."

REQUIRED_COMMANDS=(
    xfce4-session
    dbus-launch
    termux-x11
    virgl_test_server_android
    pulseaudio
    pgrep
    pkill
    ps
    xargs
)

MISSING=0

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}[OK]${RESET} $cmd"
    else
        echo "[MISSING] $cmd"
        MISSING=1
    fi
done

echo

if [[ "$MISSING" -eq 0 ]]; then
    echo -e "${GREEN}Dependency check passed.${RESET}"
else
    echo -e "${YELLOW}Some commands are missing. Check the output above.${RESET}"
    exit 1
fi
DISPLAY=$(find -iname advanced-display-5.5.3.sh)
ln "$DISPLAY" "$PREFIX/bin/display)
chmod u+x "$DISPLAY"
echo "Run your xfce desktop by running display -s"
echo "Run display -help for help"
