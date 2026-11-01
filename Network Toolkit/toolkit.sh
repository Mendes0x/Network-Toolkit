#!/usr/bin/env bash

# Network Toolkit main menu and shared helpers.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
IS_TERMUX=false
if [[ -n "${PREFIX:-}" && "${PREFIX}" == /data/data/com.termux/files/usr ]] || [[ -d /data/data/com.termux/files/usr ]]; then
    IS_TERMUX=true
fi

RED='$(printf '\033[0;31m')'
GREEN='$(printf '\033[0;32m')'
YELLOW='$(printf '\033[0;33m')'
BLUE='$(printf '\033[0;34m')'
NC='$(printf '\033[0m')'

pause_for_menu() {
    printf '\n'
    read -r -p "Press Enter to return to the main menu..." _
}

install_dependencies() {
    local -a required_commands packages missing_packages
    local i command_name package_name answer
    missing_packages=()

    if "$IS_TERMUX"; then
        required_commands=(curl nmap ip ping traceroute)
        packages=(curl nmap iproute2 inetutils traceroute)
    else
        if ! command -v apt-get >/dev/null 2>&1; then
            printf '%s[!] This installer supports Termux and Debian/Ubuntu systems with apt-get.%s\n' "$RED" "$NC" >&2
            return 1
        fi
        required_commands=(curl nmap ip ping traceroute speedtest-cli iw)
        packages=(curl nmap iproute2 iputils-ping traceroute speedtest-cli iw)
    fi

    for i in "${!required_commands[@]}"; do
        command_name="${required_commands[i]}"
        package_name="${packages[i]}"
        if ! command -v "$command_name" >/dev/null 2>&1; then
            missing_packages+=("$package_name")
        fi
    done

    if (${#missing_packages[@]} == 0)); then
        return 0
    fi

    printf '%s[*] Missing packages: %s%s\n' "$YELLOW" "${missing_packages[*]}" "$NC"
    read -r -p "Install them now? [y/N] " answer || return 1
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        printf '%s[!] Required packages were not installed.%s\n' "$RED" "$NC" >&2
        return 1
    fi

    if "$IS_TERMUX"; then
        pkg install -y "${missing_packages[@]}"
    else
        if [[ "$EUID" -eq 0 ]]; then
            apt-get update && apt-get install -y "${missing_packages[@]}"
        elif command -v sudo >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y "${missing_packages[@]}"
        else
            printf '%s[!] Install sudo or run this script as root to install packages.%s\n' "$RED" "$NC" >&2
            return 1
        fi
    fi
}

check_internet() {
    printf '%s[*] Checking internet connectivity...%s\n' "$YELLOW" "$NC"
    if ping -c 3 1.1.1.1; then
        printf '%s[+] Internet connectivity is available.%s\n' "$GREEN" "$NC"
    else
        printf '%s[!] The connectivity check failed.%s\n' "$RED" "$NC"
    fi
    pause_for_menu
}

show_network_info() {
    printf '%s=== Network interfaces ===%s\n' "$BLUE" "$NC"
    ip -brief address || ip address

    printf '\n%s=== Default gateway ===%s\n' "$BLUE" "$NC"
    ip route show default
    if "$IS_TERMUX"; then
        printf '\n%s=== DNS ===%s\n' "$BLUE" "$NC"
        getprop net.dns1 2>/dev/null || true
        getprop net.dns2 2>/dev/null || true
    else
        printf '\n%s=== DNS ===%s\n' "$BLUE" "$NC"
        awk '/^[[:space:]]*nameserver[[:space:]]+/ { print }' /etc/resolv.conf 2>/dev/null
    fi

    printf '\n%s=== Routes ===%s\n' "$BLUE" "$NC"
    ip route
    pause_for_menu
}

main_menu() {
    local choice
    while true; do
        clear 2>/dev/null || true
        printf '%s\n' "_______          __                       __     ___________           .__   __   .__  __"
        printf '%s\n' '\      \   _____/  |___  _  _____________|  | __ \__    ___/___   ____ |  | |  | _|__|/  |_'
        printf '%s\n' '/   |   \_/ __ \   __\ \/ \/ /  _ \_  __ \  |/ /   |    | /  _ \ /  _ \|  | |  |/ /  \   __\'
        printf '%s\n' '/    |    \  ___/|  |  \     (  <_> )  | \/    <    |    |(  <_> |  <_> )  |_|    <|  ||  |'
        printf '%s\n' '\____|__  /\___  >__|   \/\_/ \____/|__|  |__|_ \   |____| \____/ \____/|____/__|_ \__||__|'
        printf '%s\n' '        \/     \/                              \/                                 \/'
        printf '\nNetwork Toolkit — https://github.com/renegadothedev\n'
        printf '%s\n' '================================================'
        printf '%s\n' '1. Ping test' '2. Port scanner' '3. Speed test' '4. Traceroute' '5. Wi-Fi analyzer (Linux only)' '6. Check internet connection' '7. Network information' '8. Exit'
        read -r -p "Select an option [1-8]: " choice || break

        case "$choice" in
            1) source "${SCRIPT_DIR}/tools/ping_tool.sh" ;;
            2) source "${SCRIPT_DIR}/tools/port_scanner.sh" ;;
            3) source "${SCRIPT_DIR}/tools/speed_test.sh" ;;
            4) source "${SCRIPT_DIR}/tools/traceroute_tool.sh" ;;
            5)
                if "$IS_TERMUX"; then
                    printf '%s[!] Wi-Fi analysis is not available in Termux.%s\n' "$RED" "$NC"
                    pause_for_menu
                else
                    source "${SCRIPT_DIR}/tools/wifi_analyzer.sh"
                fi
                ;;
            6) check_internet ;;
            7) show_network_info ;;
            8) printf '%sGoodbye!%s\n' "$GREEN" "$NC"; return 0 ;;
            *) printf '%s[!] Invalid option.%s\n' "$RED" "$NC"; pause_for_menu ;;
        esac
    done
}

if ! install_dependencies; then
    printf '%s[!] Network Toolkit cannot start without its required dependencies.%s\n' "$RED" "$NC" >&2
    exit 1
fi
main_menu
