#!/bin/sh

#=============================================================#
#                                                             #
#              █████╗ ██╗   ██╗████████╗ ██████╗              #
#             ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗             #
#             ███████║██║   ██║   ██║   ██║   ██║             #
#             ██╔══██║██║   ██║   ██║   ██║   ██║             #
#             ██║  ██║╚██████╔╝   ██║   ╚██████╔╝             #
#             ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝              #
#                                                             #
#  ███████╗███████╗██╗  ██╗        ██╗  ██╗███████╗██╗   ██╗  #
#  ██╔════╝██╔════╝██║  ██║        ██║ ██╔╝██╔════╝╚██╗ ██╔╝  #
#  ███████╗███████╗███████║ █████╗ █████╔╝ █████╗   ╚████╔╝   #
#  ╚════██║╚════██║██╔══██║ ╚════╝ ██╔═██╗ ██╔══╝    ╚██╔╝    #
#  ███████║███████║██║  ██║        ██║  ██╗███████╗   ██║     #
#  ╚══════╝╚══════╝╚═╝  ╚═╝        ╚═╝  ╚═╝╚══════╝   ╚═╝     #
#                                                             #
#     Copyright (c) 2026 JB_1366 - All Rights Reserved        #
#         https://github.com/JB1366/AutoSSHKey                #
#                                                             #
#=============================================================#

SCRIPT_VERSION="1.0.1"
INSTALL_DIR="/jffs/addons/AutoSSHKey"
REPORT_SCRIPT="$INSTALL_DIR/autosshkey.sh"
CONFIG="$INSTALL_DIR/webui.conf"
if [ -f "$CONFIG" ]; then . "$CONFIG"; fi
export PATH="/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
unset LD_LIBRARY_PATH

install_menu() {
	while true; do
		clear; menu_vars
        #====================================================================#
        echo -e "                                                            "
        echo -e "              █████╗ ██╗   ██╗████████╗ ██████╗             "
        echo -e "             ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗            "
        echo -e "             ███████║██║   ██║   ██║   ██║   ██║            "
        echo -e "             ██╔══██║██║   ██║   ██║   ██║   ██║            "
        echo -e "             ██║  ██║╚██████╔╝   ██║   ╚██████╔╝            "
        echo -e "             ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝             "
        echo -e "                                                            "
        echo -e "  ███████╗███████╗██╗  ██╗        ██╗  ██╗███████╗██╗   ██╗ "
        echo -e "  ██╔════╝██╔════╝██║  ██║        ██║ ██╔╝██╔════╝╚██╗ ██╔╝ "
        echo -e "  ███████╗███████╗███████║ █████╗ █████╔╝ █████╗   ╚████╔╝  "
        echo -e "  ╚════██║╚════██║██╔══██║ ╚════╝ ██╔═██╗ ██╔══╝    ╚██╔╝   "
        echo -e "  ███████║███████║██║  ██║        ██║  ██╗███████╗   ██║    "
        echo -e "  ╚══════╝╚══════╝╚═╝  ╚═╝        ╚═╝  ╚═╝╚══════╝   ╚═╝    "
        echo -e "                                                            "
        echo -e " $JB_1366                                                   "
        echo -e "      $JB1366                                               "
        echo -e "                                                            "
        echo -e "${BL}==================================================" #==#
        check_version
        echo -e "${BL}=================================================="
        echo -e "${NC} SSH-Key: $KEY                         Port: $PORT"
        echo -e "${BL}=================================================="
        echo -e "                                                       "
        echo -e "  $N1  Install/Update                                  "
        echo -e "  $N2  Uninstall                                       "
        echo -e "  $N3  Generate RSA Keys & Provision AiMesh Nodes      "
        echo -e "  $N4  Remove RSA Keys                                 "
        echo -e "  $N5  View Authorized Keys                            "
        echo -e "  $N6  View Known Hosts                                "
        echo -e "  $N7  Node Authentication                             "
        echo -e "  $LE  Exit                                            "
        echo -e "                                                       "
        echo -e "${BL}=================================================="
        while true; do
            printf "\n ${NC}Selection: "; read -r choice
            case "$choice" in
                1) do_install; break ;;
				2|3|4|5|6|7)
                    froze || continue
                    case "$choice" in
                        2) do_uninstall; break ;;
                        3) ssh_keys; break ;;
                        4) del_ssh_keys; break ;;
                        5) echo -e "\n${BL}================ Authorized Keys =================${NC}\n"
                            if [ -f "/root/.ssh/authorized_keys" ]; then cat /root/.ssh/authorized_keys
                            else echo -e "${YL}[!] File not found.${NC}"; fi
                            echo -e "\n\n${BL}==================================================${NC}"
                            pause; break ;;
                        6) echo -e "\n${BL}================== Known Hosts  ==================${NC}\n"
                            if [ -f "/jffs/.ssh/known_hosts" ]; then cat /jffs/.ssh/known_hosts
                            else echo -e "${YL}[!] File not found.${NC}"; fi
                            echo -e "\n${BL}==================================================${NC}"
                            pause; break ;;
                        7) node_auth; break ;;
                    esac
                    break ;;
                e|E) clear; hasta; exit 0 ;;
                *) freeze 2; continue ;;

            esac
        done
    done
}

check_version() {
    local mode="$1" version_cmp=""; froze() { return 0; }
    DEV=""; if [ "$BRANCH" = "1" ]; then DEV="D"; fi
    if [ ! -f "$REPORT_SCRIPT" ]; then STATE="NOT_INSTALLED"; froze() { freeze 2; return 1; }
    elif [ -z "$REMOTE_VERSION" ]; then STATE="OFFLINE"
    else
        version_cmp=$(version_compare "$SCRIPT_VERSION" "$REMOTE_VERSION")
        case "$version_cmp" in -1|0|1) ;; *) version_cmp=0 ;; esac
        if [ "$version_cmp" -gt 0 ]; then  STATE="UP_TO_DATE"
        elif [ "$version_cmp" -lt 0 ]; then STATE="OUTDATED"
        elif [ -n "$REMOTE_HASH" ] && [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then  STATE="HASH_DIFF"
        else STATE="UP_TO_DATE"; fi
    fi
    case "$mode" in
        do_install)
            case "$STATE" in
                OUTDATED)      echo -e "\n${GR}[i] A new version (${NC}v$REMOTE_VERSION${GR}) is available!${NC}\n"
                               UP="update version?" ;;
                HASH_DIFF)     echo -e "\n${GR}[i] There is a Hash Update for (${NC}v$SCRIPT_VERSION$DEV${GR}).${NC}\n"
                               UP="update Hash?" ;;
                UP_TO_DATE|*)  echo -e "\n${GR}[i] You are already on the latest version (${NC}v$SCRIPT_VERSION$DEV${GR}).${NC}\n"
                               UP="reinstall/overwrite anyway?";;
            esac ;;
        *)
            case "$STATE" in
                OFFLINE)       echo -e "$STATUS [Offline]         ${RD}Could not reach GitHub${NC}" ;;
                NOT_INSTALLED) echo -e "$STATUS [Not Installed] ${BL}Latest Available:${NC} v$REMOTE_VERSION"; N1="${BL}(1)" ;;
                OUTDATED)      echo -e "$STATUS [v$REMOTE_VERSION Available]      $CURRENT" ;;
                HASH_DIFF)     echo -e "$STATUS [Hash Update Available] $CURRENT" ;;
                UP_TO_DATE|*)  echo -e "$STATUS [Up to date]            $CURRENT" ;;
            esac ;;
    esac
}

version_compare() {
    awk -v left="$1" -v right="$2" '
        function num(part) { return (part ~ /^[0-9]+$/) ? part + 0 : 0 }
        BEGIN {
            lc = split(left, L, "."); rc = split(right, R, ".")
            max = (lc > rc) ? lc : rc
            for (i = 1; i <= max; i++) {
                lv = (i <= lc) ? num(L[i]) : 0
                rv = (i <= rc) ? num(R[i]) : 0
                if (lv < rv) { print -1; exit }
                if (lv > rv) { print 1; exit }
            }
            print 0
        }'
}

menu_vars() {
    if [ -f "$CONFIG" ]; then . "$CONFIG"; fi
    DEV=""; if [ "$BRANCH" = "1" ]; then DEV="D"; fi
	trap 'printf "\033[0m"' 0; trap 'exit 130' INT TERM HUP
    UL='\033[4m'; WH='\e[1;37m'; YL='\033[0;33m'; NC='\033[0m'
    BL='\033[38;5;39m'; GR='\033[0;32m'; RD='\033[0;31m'
    JB_1366="${NC}Copyright (c) 2026 JB_1366 - All Rights Reserved"
    JB1366="${GR}${UL}https://github.com/JB1366/AutoSSHKey${NC}"
	for i in 0 1 2 3 4 5 6 7 8 9 10; do eval "N${i}=\"\${BL}(${i})\${NC}\""; done
	for i in E C R; do eval "L${i}=\"\${BL}(${i})\${NC}\""; done
    SS_FILE="/jffs/scripts/services-start"
    ON="${GR}ON${NC}"; OFF="${RD}OFF${NC}"; echo -e "${BL}"
	STATUS=" ${BL}STATUS:${NC}"; CURRENT="${BL}CURRENT:${NC} v$SCRIPT_VERSION$DEV"
	if [ -z "$SSH_KEY" ]; then KEY="${RD}NO${NC}"; else KEY="${GR}YES${NC}"; fi
	PORT="${GR}$SSH_PORT${NC}"
}

do_install() {
	mkdir -p "$INSTALL_DIR" 2>/dev/null
    if [ ! -f "$CONFIG" ]; then touch "$CONFIG"; fi
	local is_update=0
	if [ -f "$REPORT_SCRIPT" ]; then is_update=1; fi
	if [ "$is_update" = "1" ]; then
        while true; do
            check_version do_install
            printf "Do you want to $UP (y/n): "; read -r update
            case "$update" in y|Y) break ;; n|N) return ;; *) freeze 4 ;; esac; done
    fi
    do_update || return 1
    echo -e "\n${GR}[+] Downloading latest version (${NC}v$REMOTE_VERSION${GR})${NC}"
	if [ "$is_update" = "1" ]; then
		echo -e "\n${BL}[✓] Auto SSH Key successfully installed.${NC}"
		printf "\nPress ${BL}[Enter]${NC} to apply changes & restart script..."; read -r discard
		logger -p user.info -t "Auto SSH Key" "(v$REMOTE_VERSION) successfully installed."
		exec "$REPORT_SCRIPT" install "$@"
		echo -e "${RD}Error: Failed to restart script!${NC}" >&2
		exit 1
	fi
    if [ "$(nvram get jffs2_scripts)" != "1" ]; then
        echo -e "${RD}[!] ERROR: JFFS custom scripts not enabled.${NC}"
        pause; return 1
    fi
	if [ -f "$SSH_KEY" ]; then node_auth
	else ssh_keys || return 1; fi
    echo -e "\n${GR}[+] Processing Auto SSH Key Files...${NC}\n"
    SCRIPT_VERSION="$REMOTE_VERSION"
    logger -p user.info -t "Auto SSH Key" "(v$REMOTE_VERSION) successfully installed."
    echo -e "${GR}[✓] SUCCESS: Installation complete!${NC}\n"
	pause
}

do_update() {
    TEMP_SCRIPT="/tmp/autosshkey.sh"
    if curl -sfL --retry 3 "$GITHUB" -o "$TEMP_SCRIPT" && [ -s "$TEMP_SCRIPT" ]; then
        mv "$TEMP_SCRIPT" "$REPORT_SCRIPT"
        chmod +x "$REPORT_SCRIPT" 2>/dev/null
        return 0
    else
        rm -f "$TEMP_SCRIPT"
        if [ ! -f "$0" ]; then
            echo -e "${RD}[!] Download failed. Aborting installation.${NC}"
            return 1
        fi
        local CURRENT_PATH; local TARGET_PATH
        CURRENT_PATH=$(readlink -f "$0" 2>/dev/null)
        [ -z "$CURRENT_PATH" ] && CURRENT_PATH="$0"
        TARGET_PATH=$(readlink -f "$REPORT_SCRIPT" 2>/dev/null)
        [ -z "$TARGET_PATH" ] && TARGET_PATH="$REPORT_SCRIPT"
        if [ "$CURRENT_PATH" != "$TARGET_PATH" ]; then
            echo -e "\n${YL}[!] GitHub unreachable. Installing current local copy...${NC}\n"
            cp "$0" "$REPORT_SCRIPT"
            chmod +x "$REPORT_SCRIPT" 2>/dev/null
            return 0
        else
            echo -e "${RD}[!] GitHub unreachable and script is already in place.${NC}"
            return 1
        fi
    fi
}

ScriptUpdateFromAMTM() {
    doScriptUpdateFromAMTM=true
    if [ "$doScriptUpdateFromAMTM" != "true" ]; then
        printf "Automatic updates via AMTM are currently disabled."
        return 1
    fi
    if [ "$1" = "check" ]; then return 0; fi
    if check_github && do_update; then
        echo -e "  [+] Downloading latest version (v$REMOTE_VERSION)\n\n"
        echo -e "  [✓] Auto SSH Key successfully updated.\n"
		logger -p user.info -t "Auto SSH Key" "AMTM Update: (v$REMOTE_VERSION) successfully installed."
		return 0
    fi
    return 1

}

wr_sha256() {
    local file="$1" hash=""
    [ -f "$file" ] || return 1
    if command -v sha256sum >/dev/null 2>&1; then
        hash=$(sha256sum "$file" 2>/dev/null | awk '{print $1}')
    elif command -v busybox >/dev/null 2>&1 && busybox sha256sum "$file" >/dev/null 2>&1; then
        hash=$(busybox sha256sum "$file" 2>/dev/null | awk '{print $1}')
    elif command -v openssl >/dev/null 2>&1; then
        hash=$(openssl dgst -sha256 "$file" 2>/dev/null | awk '{print $NF}')
    fi
    [ "${#hash}" -eq 64 ] || return 1
    printf '%s\n' "$hash"
}

check_github() {
    GITHUB="https://raw.githubusercontent.com/JB1366/AutoSSHKey/main/autosshkey.sh"
    REMOTE_TMP="/tmp/wr_remote.tmp"; LOCAL_HASH=""; REMOTE_HASH=""
    if curl -sfL --retry 3 "$GITHUB" -o "$REMOTE_TMP" 2>/dev/null && [ -s "$REMOTE_TMP" ]; then
        REMOTE_VERSION=$(grep "SCRIPT_VERSION=" "$REMOTE_TMP" | head -n 1 | cut -d'"' -f2 | tr -cd '0-9.')
        LOCAL_HASH=$(wr_sha256 "$REPORT_SCRIPT" 2>/dev/null)
        REMOTE_HASH=$(wr_sha256 "$REMOTE_TMP" 2>/dev/null)
        if [ -z "$LOCAL_HASH" ] || [ -z "$REMOTE_HASH" ]; then
            if [ -f "$REPORT_SCRIPT" ]; then
                if cmp -s "$REPORT_SCRIPT" "$REMOTE_TMP"; then LOCAL_HASH="same"; REMOTE_HASH="same"
                else LOCAL_HASH="local"; REMOTE_HASH="remote"; fi
            fi
        fi
    else REMOTE_VERSION=""; REMOTE_HASH=""; fi
    rm -f "$REMOTE_TMP"
}

ssh_init() {
	NODE_USER=$(nvram get http_username)
	SSH_PORT=$(nvram get sshd_port); SSH_PORT=${SSH_PORT:-22}
	if [ -f "/root/.ssh/id_dropbear" ]; then SSH_KEY="/root/.ssh/id_dropbear"
	else  SSH_KEY=""; fi
}

node_auth() {
    if [ ! -s "$SSH_KEY" ]; then
        echo -e "\n${YL}[!] Main Router SSH Key not found.${NC}"
        pause; return
    fi
	sed -i '/^SSH_NODES=/d' "$CONFIG"
	echo -e "\n${GR}[✓] Main Router SSH Key found at: ${WH}$SSH_KEY${NC}\n"
	echo -e "${BL}=================================================="
    echo -e "${NC}         Verifying Node Authentication            "
    echo -e "${BL}==================================================\n"
	AIMESH_NODES=$(nvram get asus_device_list | sed 's/</\n/g' | grep '>2$' | awk -F '>' '{print $2 "|" $3}' | sort -t . -k 4,4n)
	if [ -z "$AIMESH_NODES" ]; then
		AIMESH_NODES=$(nvram get cfg_device_list | sed 's/</\n/g' | grep '>0$' | awk -F '>' '{print $1 "|" $2}' | sort -t . -k 4,4n)
	fi
    if [ -z "$AIMESH_NODES" ]; then
        echo -e "\n${RD}[!] No AiMesh Nodes detected in NVRAM.${NC}"
        TOTAL_NODES=0; any_success=0
    else
        TOTAL_NODES=$(echo "$AIMESH_NODES" | grep -o "|" | wc -l)
		any_success=0; VALID_NODES=""; new_nodes=0
        for line in $AIMESH_NODES; do
			ROUTER="${line%%|*}"; IP="${line#*|}"
            [ -z "$IP" ] || [ "$IP" = "$ROUTER" ] && continue
			if [ -z "$ROUTER" ]; then ROUTER="Node_$IP"; fi
			printf "${NC}[*] Testing ${GR}%-14s${NC} (%s) " "$ROUTER" "$IP"
            SSH_ERR=$(/usr/bin/ssh -p "$SSH_PORT" -i "$SSH_KEY" -o StrictHostKeyChecking=no -o BatchMode=yes "${NODE_USER}@${IP}" "exit" 2>&1 >/dev/null)
			SSH_RC=$?
			if [ "$SSH_RC" -eq 0 ]; then
				echo -e "${GR}[✓] AUTHENTICATED${NC}"
				any_success=$((any_success + 1))
				VALID_NODES="$VALID_NODES $ROUTER|$IP"
				if ! grep -q "$IP" /jffs/.ssh/known_hosts 2>/dev/null; then
					echo -ne "    Capturing fingerprint & updating known_hosts "
					dbclient -y -p "$SSH_PORT" "$IP" "exit" > /dev/null 2>&1
					if grep -q "$IP" /root/.ssh/known_hosts 2>/dev/null; then
						grep "$IP" /root/.ssh/known_hosts >> /jffs/.ssh/known_hosts
						sort -u /jffs/.ssh/known_hosts -o /jffs/.ssh/known_hosts
						echo -e "${GR}[✓] DONE${NC}"
						new_nodes=$((new_nodes + 1))
						TARGET_KEY=$(awk -v ip="$IP" '$1 ~ ip {print $2, $3}' /jffs/.ssh/known_hosts 2>/dev/null)
						if [ -n "$TARGET_KEY" ]; then
							echo -e "    Node Host Key: ${BL}$TARGET_KEY${NC}"
						fi
					else
						echo -e "${RD}[✗] FAILED${NC}"
					fi
				fi
			else
				if echo "$SSH_ERR" | grep -q "No auth methods"; then
					echo -e "${RD}[✗] Failed: Invalid Username or SSH Key.${NC}"
				elif echo "$SSH_ERR" | grep -q "Connection refused"; then
					echo -e "${RD}[✗] Failed: SSH Connection refused.${NC}"
				else
					echo -e "${RD}[✗] Failed: Unknown connection issue.${NC}"
				fi
			fi
		done
    fi
    sed -i '/SSH_NODES=/d' "$CONFIG"
    if [ -z "$VALID_NODES" ]; then echo 'SSH_NODES=" "' >> "$CONFIG"
    else echo "SSH_NODES=\"$VALID_NODES\"" >> "$CONFIG"; fi
    if [ "$any_success" -gt 0 ] && [ "$any_success" -eq "$TOTAL_NODES" ]; then
        echo -e "\n${GR}[✓] All nodes ($any_success/$TOTAL_NODES) authenticated successfully!${NC}"
        if [ "$new_nodes" -gt 0 ]; then
            [ "$new_nodes" -eq 1 ] && suffix="" || suffix="s"
            echo -e "\n${YL}[!] $new_nodes new node$suffix successfully authenticated.${NC}"
        fi
        pause; return
    else
        if [ "$any_success" -gt 0 ]; then
            echo -e "\n${YL}[!] Partial Success: Only $any_success of $TOTAL_NODES nodes authenticated.${NC}"
            ACTION_MSG="Continue with current nodes only"
            KEY_LBL="$LC"
        else
            echo -e "\n${RD}[!] CRITICAL: SSH authentication failed on all nodes.${NC}\n"
            ACTION_MSG="No Nodes Detected"
            KEY_LBL="$LR"
        fi
        echo -e "\n Choices:\n"
        echo -e "  ${BL}(Enter)${NC} Retry authentication"
        echo -e "  ${BL}$KEY_LBL${NC}     $ACTION_MSG"
        echo -e "  ${BL}$LE     Exit to main menu\n"
        printf "\n ${NC}Selection: "; read -r choice
        case "$choice" in
            [rR]|[cC])
                echo -e "\n\n${YL}[!] $ACTION_MSG...${NC}\n"
                if [ "$any_success" -eq 0 ]; then
                    sed -i '/SSH_NODES=/d' "$CONFIG"
                    echo 'SSH_NODES=" "' >> "$CONFIG"
                fi
                echo -e "${GR}[✓] Environment configuration locked in.${NC}"
                pause; return ;;
            e|E)
                return ;;
            *)
                echo -e "\n\n${BL}[i] Retrying authentication...${NC}"
                sleep 5
                node_auth; return ;;
        esac
    fi
}

ssh_keys() {
	if [ -f "$SSH_KEY" ]; then
		echo -e "\n${YL}[!] Main Router SSH Key already exists.${NC}"
		pause; return 0
	fi
	if [ -f "/jffs/.ssh/id_dropbear" ] && [ ! -f "/root/.ssh/id_dropbear" ]; then
		while true; do
            printf "\n${NC}Stored key detected in /jffs/.ssh/, Proceed? (y/n): "; read -r update
            case "$update" in y|Y) break ;; n|N) return ;; *) freeze 2 ;; esac; done
        echo -e "\n${GR}[!]  Linking and configuring...${NC}\n"
	fi
    if [ ! -f "/jffs/.ssh/id_dropbear" ]; then
        while true; do
            printf "\n${NC}Do you want to create RSA Key (y/n): "; read -r update
            case "$update" in y|Y) break ;; n|N) return ;; *) freeze 2 ;; esac; done
        echo -e "\n${YL}[i] Creating RSA Key in /jffs/.ssh/${NC}\n"
        mkdir -p /jffs/.ssh
        dropbearkey -t rsa -f /jffs/.ssh/id_dropbear
    fi
	rm -f /jffs/.ssh/known_hosts /root/.ssh/known_hosts >/dev/null 2>&1
    mkdir -p /root/.ssh
    cp /jffs/.ssh/id_dropbear /root/.ssh/id_dropbear
    echo -e "\n${BL}[i] Copying /jffs/.ssh/id_dropbear to /root/.ssh/id_dropbear${NC}\n"
	SSH_KEY="/root/.ssh/id_dropbear"
    local pub_key=$(dropbearkey -y -f "/root/.ssh/id_dropbear" | grep "^ssh-rsa")
    local current_keys=$(nvram get sshd_authkeys)
	local combined_keys=$(printf "%s\n%s" "$current_keys" "$pub_key" | sed '/^$/d' | sort -u)
	echo -e "\n${YL}[i] Injecting Key into NVRAM...${NC}\n"
	nvram set sshd_authkeys="$combined_keys"
    nvram commit
	nvram get sshd_authkeys > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    if [ ! -f "$SS_FILE" ]; then echo "#!/bin/sh" > "$SS_FILE" && chmod +x "$SS_FILE"; fi
    if ! grep -q "id_dropbear" "$SS_FILE"; then
        echo -e "\n${YL}[i] Adding SSH Key to services-start for persistence on reboots...${NC}"
		echo -e "\n${YL}[i] Adding known_hosts to services-start...${NC}\n"
		echo "cp /jffs/.ssh/id_dropbear /tmp/home/root/.ssh/id_dropbear # sshpairs" >> "$SS_FILE"
        echo "cp /jffs/.ssh/known_hosts /tmp/home/root/.ssh/known_hosts # sshpairs persistence" >> "$SS_FILE"
    fi
	echo -e "${BL}=================================================="
	echo -e "${NC}               ACTION REQUIRED NOW                "
    echo -e "${BL}=================================================="
    echo -e "                                                       "
	echo -e "[*] STEP 1: Go to Asus WebGUI > AiMesh > Management    "
	echo -e "[*] STEP 2: Click 'Reboot Node' for each node\n        "
	echo -e "${YL}[!] Do not press [Enter] until Nodes are confirmed to be back online.\n"
	echo -e "${BL}[*] TIP: If a node is missing after authentication,     "
	echo -e "${BL}[*]      use option #7 to reauthenticate.          ${NC}"
	printf "\n[*] Press ${BL}[ENTER]${NC} to begin authentication check..."; read -r discard
	node_auth
}

del_ssh_keys() {
	if [ -f "$SSH_KEY" ]; then
		echo -e "\n${YL}[!] Main Router SSH Key exists.${NC}\n"
        while true; do
            printf "Do you want to delete Key? (y/n): "; read -r delete
            case "$delete" in y|Y) break ;; n|N) return ;; *) freeze ;; esac; done
	else
		echo -e "\n${YL}[!] No active RSA key found to delete.${NC}"
		pause; return
	fi
	echo -e "\n${YL}[i] Purging RSA key footprint from environment...${NC}"
	if [ -f "/jffs/.ssh/id_dropbear.pub" ]; then
		PUB_STRING=$(awk '{print $2}' /jffs/.ssh/id_dropbear.pub)
	else
		PUB_STRING=""
	fi
	if [ -n "$PUB_STRING" ] && [ -f "/root/.ssh/authorized_keys" ]; then
		sed -i "\|$PUB_STRING|d" /root/.ssh/authorized_keys
	fi
	NVRAM_KEYS=$(nvram get sshd_authkeys)
	if [ -n "$PUB_STRING" ] && echo "$NVRAM_KEYS" | grep -q "$PUB_STRING"; then
		CLEANED_KEYS=$(echo "$NVRAM_KEYS" | grep -v "$PUB_STRING")
		nvram set sshd_authkeys="$CLEANED_KEYS"
		nvram commit
	fi
	rm -f "/jffs/.ssh/id_dropbear" "/jffs/.ssh/id_dropbear.pub" "/root/.ssh/id_dropbear" >/dev/null 2>&1
	rm -f /jffs/.ssh/known_hosts /root/.ssh/known_hosts >/dev/null 2>&1
    nvram get sshd_authkeys > /root/.ssh/authorized_keys
	chmod 600 /root/.ssh/authorized_keys
	echo -e "\n${GR}[✓] RSA Keys removed successfully.${NC}"
	ssh_init; pause
}

do_uninstall() {
    echo -e "\n${RD}[!] WARNING: Removing Auto SSH Key...${NC}\n"
    while true; do
        printf "Are you sure? (y/n): "; read -r confirm
        case "$confirm" in y|Y) break ;; n|N) return ;; *) freeze ;; esac; done
	if [ -f "$CONFIG" ]; then . "$CONFIG"; fi
	ssh_init
    rm -rf "$INSTALL_DIR" 2>/dev/null
	logger -p user.info -t "Auto SSH Key" "(v$SCRIPT_VERSION) successfully uninstalled."
	echo -e "\n${GR}[+] System cleaned. SSH Keys and Fingerprints preserved in /jffs/.ssh${NC}"
	echo -e "\n${GR}[+] Success: Auto SSH Key uninstalled.${NC}"
	pause
}

pause() { printf "\nPress ${BL}[Enter]${NC} to return..."; read -r discard; }

freeze() { printf "\033[%dA\033[J" "${1:-1}"; }

check_github; ssh_init

hasta() {
echo -e "\n\n\n${BL}" #===========================================================================================================
echo -e "                                                                                                                        "
echo -e "                                                                                                                        "
echo -e "             ██╗  ██╗ █████╗ ███████╗████████╗ █████╗      ██╗      █████╗      ██╗   ██╗██╗███████╗████████╗ █████╗    "
echo -e "    ██╗      ██║  ██║██╔══██╗██╔════╝╚══██╔══╝██╔══██╗     ██║     ██╔══██╗     ██║   ██║██║██╔════╝╚══██╔══╝██╔══██╗   "
echo -e "             ███████║███████║███████╗   ██║   ███████║     ██║     ███████║     ██║   ██║██║███████╗   ██║   ███████║   "
echo -e "    ██║      ██╔══██║██╔══██║╚════██║   ██║   ██╔══██║     ██║     ██╔══██║     ╚██╗ ██╔╝██║╚════██║   ██║   ██╔══██║   "
echo -e "    ██║      ██║  ██║██║  ██║███████║   ██║   ██║  ██║     ███████╗██║  ██║      ╚████╔╝ ██║███████║   ██║   ██║  ██║   "
echo -e "    ██║      ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝     ╚══════╝╚═╝  ╚═╝       ╚═══╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝   "
echo -e "    ╚═╝                                                                                                                 "
echo -e "                                                                                                                        "
echo -e "${NC}\n\n\n" #===========================================================================================================
}

case "$1" in
    install)
        install_menu
        ;;
    amtmupdate)
		shift
        ScriptUpdateFromAMTM "$@"
        exit "$?"
        ;;
	*)
        install_menu
        ;;
esac