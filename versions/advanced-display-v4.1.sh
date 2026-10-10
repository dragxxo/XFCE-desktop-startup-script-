#!/data/data/com.termux/files/usr/bin/bash
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'
MAGENTA='\e[35m'

RISH="$HOME/rish"
if [ ! -x "$RISH" ]; then
    echo "ERROR: RISH binary not found or not executable or its might be in ur ass:"
    echo "$RISH"
    echo "make sure to Run: chmod +x ~/rish"
    echo "connect shizuku with termux"
    echo "please follow the official giude"
    exit 1
fi
if ! "$RISH" -c 'echo RISH_OK' >/dev/null 2>&1; then
    echo -e "${RED}ERROR FATAL: Cannot communicate with Shizuku through RISH.${RESET}" >&2
    echo "${YELLOW}Make sure Shizuku is running.${RESET}" >&2
    exit 1
fi
sleep 2
"$RISH" -c "/system/bin/device_config put activity_manager max_phantom_processes 2147483647" && echo -e ${BLUE}" Success XFCE desktop stability accrued "${RESET} || echo -e ${MAGENTA}"ERROR CRITICAL:" ${RESET} "XFCE environment many experence instability"
sleep 3
if "$RISH" -c "pm list packages | grep com.termux.x11"2>&1;then
    termux-x11 :1 >/dev/null 2>&1 &
    X11_PID=$!
    sleep 3
    if kill -0 "$X11_PID" 2>/dev/null; then
    	 echo -e "${BLUE}CONNECTION TO SERVER X SUCCESS${RESET}"
    else
    	echo -e "${RED}ERROR FATAL: Failed to establish X server${RESET}">&2
    	echo -e "${GREEN}TIP${RESET}:Make sure there are no instances running">&2
	exit 1
    fi
else
    echo -e "${RED}ERROR FATAL${RESET}: Termux-x11 app not found">&2
    echo -e "${BLUE}INSTALL${GREEN}termux-x11${RESET} from  https://github.com/termux/termux-x11.git" 
    exit 1
fi
sleep 3
virgl_test_server_android > "$HOME/virgl.log" 2>&1 &
virgl_PID=$!
sleep 3
if kill -0 "$virgl_PID" 2>/dev/null; then
    echo -e "${BLUE}CONNECTION TO VIRGL SERVER SUCCESS${RESET}"
    rm -f "$HOME/virgl.log"
else
    echo -e "${YELLOW}WARRING${RESET} : failed to initialize GPU, defalting to software rendering"
    cat "$HOME/virgl.log"
    rm -f "$HOME/virgl.log"
fi
sleep 3
export GALLIUM_DRIVER=virpipe
sleep 2
export DISPLAY=:1
sleep 2
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 || echo -e "${YELLOW}WARRING${RESET}:failed to initialize pulseaudio server">&2
sleep 2
export PULSE_SERVER=127.0.0.1
sleep 2
"$RISH" -c  "monkey -p com.termux.x11 -c android.intent.category.LAUNCHER 1"
dbus-launch --exit-with-session xfce4-session > "$HOME/XFCE.log" 2>&1 &
XFCE_PID=$!
wait $XFCE_PID
EXIT_CODE=$?
if ["$EXIT_CODE" -ne 0]; then
    echo -e "${RED}XFCE DESKTOP session have crashed with id exit code $EXIT_CODE${RESET}"
    cat "$HOME/XFCE.log"
    rm -f "$HOME/XFCE.log"
fi



