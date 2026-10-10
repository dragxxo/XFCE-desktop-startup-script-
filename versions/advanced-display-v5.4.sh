#!/data/data/com.termux/files/usr/bin/bash
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'
MAGENTA='\e[35m'
Dependencies=("xfce4-session" "dbus-launch" "termux-x11")
for cmd in "${Dependencies[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${RED}ERROR: Dependency '$cmd' is missing or not executable${RESET}"
        exit 1
    fi
done
termux_x11()
{
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
}
show_version()
{
	echo -e "${YELLOW}VERSION 5.4"
	echo -e "EXPERIMENTAL"
}
show_help()
{
	echo -e "${GREEN}usage : display $0 [options]${RESET}"
	echo -e "${GREEN}  -s, --start${BLUE}     	Start the session"
	echo -e "${GREEN}  --no-gpu${BLUE}        	Disable GPU acceleration"
	echo -e "${GREEN}  --no-audio${BLUE}      	Disable audio output"
	echo -e "${GREEN}  -vv, --verbose${BLUE}  	Enable verbose logging"
	echo -e "${GREEN}  -h, --help${BLUE}      	Show this help message"
	echo -e "${GREEN}  -v, --version${BLUE} 	To show the current version${RESET}"
	echo -e "${GREEN}  --disable-shizuku${BLUE}	To skip shizuku inteigeraion use this flag if shizuku/rish keeps failing${RESET}"
	echo -e "${GREEN}  -e,--stop${BLUE}		To exit the xfce desktop${RESET}"
}
exit_xfce()
{
	echo -e "${YELLOW}SHUTTING DOWN.....${RESET}"
	PROCESS_ID=$(pgrep -x -n xfce4-session)
	SESSION_ID=$(ps -o sid= -p "$PROCESS_ID" 2>/dev/null)
	if [[ -n "$SESSION_ID" ]] ; then
		XFCE_SID=$(echo "$SESSION_ID" | xargs)
		if [[ "$XFCE_SID" =~ ^[0-9]+$ ]] ; then
			pkill -TERM -s "$XFCE_SID"
			exit 0
		else
			echo -e "${RED}INVALID SESSION ID: PLEASE KILL THIS SESSION MANUALLY${RESET}"
			echo -e "	PROCESS_ID=$PROCESS_ID \n	SESSION_ID=$SESSION_ID"
			exit 1
		fi
	else
		echo "${RED}NO SESSION ID FOUND: PLEASE KILL THIS SESSION MANUALLY${RESET}"
		exit 1
	fi
}
START=true
NO_GPU=false
NO_AUDIO=false
VERBOSE=false
DISABLE_SHIZUKU=false
while [[ $# -gt 0 ]]; do
	case "$1" in
		-s|--start) START=false ;;
		--no-gpu) NO_GPU=true ;;
		--no-audio) NO_AUDIO=true ;;
		-vv|--verbose) VERBOSE=true ;;
		--disable-shizuku|--disable-rish) DISABLE_SHIZUKU=true ;;
		-h|--help) show_help
			exit 0 ;;
		-e|--stop) exit_xfce ;;
		-v|--version) show_version
			exit 0 ;;
		*) echo -e "${RED}ERROR: unknown option '$1'${RESET}" >&2
			exit 1 ;;
	esac
	shift 
done
if ! $START ; then
	if ! $DISABLE_SHIZUKU ; then
		RISH="$HOME/rish"
		if [ ! -x "$RISH" ]; then
			echo "ERROR: RISH binary not found or not executable: "
			echo "$RISH"
			echo "make sure to Run: chmod +x ~/rish"
			echo "connect shizuku with termux"
			echo "please follow the official guide"
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
		if "$RISH" -c "pm list packages | grep com.termux.x11" >/dev/null 2>&1;then
			termux_x11
		else
			echo -e "${RED}ERROR FATAL${RESET}: Termux-x11 app not found">&2
			echo -e "${BLUE}INSTALL${GREEN}termux-x11${RESET} from  https://github.com/termux/termux-x11.git" 
			exit 1
		fi
	fi
	if $DISABLE_SHIZUKU ; then
		termux_x11
	fi
	sleep 3
	if ! $NO_GPU ; then
		virgl_test_server_android > "$HOME/virgl.log" 2>&1 &
		virgl_PID=$!
		sleep 3
		if kill -0 "$virgl_PID" 2>/dev/null; then
			echo -e "${BLUE}CONNECTION TO VIRGL SERVER SUCCESS${RESET}"
			rm -f "$HOME/virgl.log"
		else
			echo -e "${YELLOW}WARNING${RESET} : failed to initialize GPU, defalting to software rendering"
			cat "$HOME/virgl.log"
			rm -f "$HOME/virgl.log"
		fi
		sleep 3
		export GALLIUM_DRIVER=virpipe
	fi
	if $NO_GPU ; then
		export GALLIUM_DRIVER=llvmpipe
		echo -e "${YELLOW}USING SOFTWARE RENDERING : llvmpipe ${RESET}"
	fi
	sleep 2
	export DISPLAY=:1
	sleep 2
	if ! $NO_AUDIO ; then
		pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 && echo -e "${BLUE}CONNECTION TO PULSEAUDIO SERVER SUCCESS${RESET}"|| echo -e "${YELLOW}WARNING${RESET}:failed to initialize pulseaudio server">&2
		sleep 2
		export PULSE_SERVER=127.0.0.1
	fi
	if $NO_AUDIO ; then
		echo -e "${BLUE}BROWSER WONT OUTPUT AUDIO${RESET}"
	fi
	sleep 2
	if ! $DISABLE_SHIZUKU ; then
		"$RISH" -c  "am start -n com.termux.x11/.MainActivity" >/dev/null 2>&1 || kill "$virgl_PID" "$X11_PID";
	fi
	dbus-launch --exit-with-session xfce4-session > "$HOME/XFCE.log" 2>&1 &
	XFCE_PID=$!
	sleep 2
#	XFCE_SESSION_PID=(pgrep -x -n xfce4-session)
#	if [[ -n "$XFCE_SESSION_PID" ]] ; then
#		XFCE_SID=$(ps -o sid= -p "$XFCE_SESSION_PID" | tr -d ' ')
#		echo "$XFCE_SID" > "$HOME/.display_sid"
#	fi
	wait $XFCE_PID
	EXIT_CODE=$?
	if [ "$EXIT_CODE" -ne 0 ]; then
		echo -e "${RED}XFCE DESKTOP session have crashed with id exit code $EXIT_CODE${RESET}"
		cat "$HOME/XFCE.log"
		rm -f "$HOME/XFCE.log"
	fi
	echo -e "${GREEN}XFCE SESSION EXITED WITH CODE 0${RESET}"
fi
show_help


