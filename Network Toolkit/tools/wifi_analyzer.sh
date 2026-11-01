#!/usr/bin/env bash

wifi_analyzer() {
    local interface choice scan_output
    clear 2>/dev/null || true
    printf '%s=== Wi-Fi analyzer ===%s\n\n' "$BLUE" "$NC"

    if ! command -v iw >/dev/null 2>&1; then
        printf '%s[!] The iw command is missing. Install the iw package first.%s\n' "$RED" "$NC"
        pause_for_menu
        return
    fi

    interface="$(iw dev 2>/dev/null | awk '$1 == "Interface" { print $2; exit }')"
    if [[ -z "$interface" ]]; then
        printf '%s[!] No wireless interface was found.%s\n' "$RED" "$NC"
        pause_for_menu
        return
    fi

    printf '%s[*] Using wireless interface: %s%s\n\n' "$YELLOW" "$interface" "$NC"
    printf '%s\n' '1. Scan for nearby Wi-Fi networks' '2. Show current connection details' '3. Return to the main menu'
    read -r -p "Select an option [1-3]: " choice || return

    case "$choice" in
        1)
            if ! command -v sudo >/dev/null 2>&1 && [[ "$EUID" -ne 0 ]]; then
                printf '%s[!] Install sudo or run the scan as root; scanning needs elevated privileges.%s\n' "$RED" "$NC"
                pause_for_menu
                return
            fi
            printf '%s[*] Scanning nearby networks. This can take a few seconds...%s\n' "$YELLOW" "$NC"
            if [[ "$EUID" -eq 0 ]]; then
                scan_output="$(iw dev "$interface" scan 2>&1)"
            else
                scan_output="$(sudo iw dev "$interface" scan 2>&1)"
            fi
            if [[ -z "$scan_output" ]]; then
                printf '%s[!] No scan results were returned. Check that the adapter is enabled.%s\n' "$RED" "$NC"
            else
                printf '%s\n' "$scan_output" | awk '
                    /^BSS / {
                        if (ssid != "") print "SSID: " ssid " | Signal: " signal " | Frequency: " frequency
                        ssid = "(hidden or not yet read)"
                        signal = "unknown"
                        frequency = "unknown"
                    }
                    /^[[:space:]]*SSID:/ {
                        sub(/^[[:space:]]*SSID:[[:space:]]*/, "")
                        if (length($0)) ssid = $0
                    }
                    /^[[:space:]]*signal:/ { signal = $2 " dBm" }
                    /^[[:space:]]*freq:/ { frequency = $2 " MHz" }
                    END {
                        if (ssid != "") print "SSID: " ssid " | Signal: " signal " | Frequency: " frequency
                    }
                '
            fi
            ;;
        2)
            printf '%s=== Current wireless link ===%s\n' "$BLUE" "$NC"
            iw dev "$interface" link
            printf '\n%s=== IP address ===%s\n' "$BLUE" "$NC"
            ip -brief address show dev "$interface"
            ;;
        3) return 0 ;;
        *) printf '%s[!] Invalid option.%s\n' "$RED" "$NC" ;;
    esac
    pause_for_menu
}

wifi_analyzer
