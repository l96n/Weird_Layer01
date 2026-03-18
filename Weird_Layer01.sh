#!/bin/bash

# ===============================
#        WEIRD - Layer_01
#   Ghost Lab Stealth Web Audit
# ===============================

# Main directory
MASTER_SCRIPTS_DIR="$HOME/Weird/"
LOG_DIR="$MASTER_SCRIPTS_DIR/Weird_Log"
SCRIPT_NAME="Weird_Layer01.sh"

mkdir -p "MASTER_SCRIPTS_DIR"
mkdir -p "$LOG_DIR"

# ANSI Colors
RED='\e[31m'
GREEN='\e[32m'
ORANGE='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
MAGENTA='\e[35m'
RESET='\e[0m'

clear

# Header
 echo -e "${MAGENTA}============== GHOST LAB ==============${RESET}"
 echo -e "${CYAN}========== WEIRD - Layer_01 ===========${RESET}"
 echo -e "${GREEN} Stealth Web Audit via Tor + Proxychains4 ${RESET}"
 echo -e "${BLUE} JS, Forms, Cookies, API, DNS, WHOIS Analysis ${RESET}"
 echo

# Check URL argument
if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 <url>${RESET}"
    exit 1
fi

URL="$1"
[[ ! "$URL" =~ ^https?:// ]] && URL="https://$URL"

BASE_DOMAIN=$(echo "$URL" | awk -F/ '{print $3}')
DATE_LOG=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="$LOG_DIR/${BASE_DOMAIN}_${DATE_LOG}.log"

# Random User-Agent rotation
USER_AGENTS=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/115.0 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/605.1.15"
    "Mozilla/5.0 (X11; Linux x86_64) Firefox/114.0"
    "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6) Safari/605.1.15"
)
RANDOM_UA=${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]}]}
CURL_OPTS=(-s -A "$RANDOM_UA" --socks5-hostname 127.0.0.1:9050 --max-time 15)

# ===============================
# API CONFIGURATION (EDIT HERE)
# ===============================
# Insert your own API token below if you want extended IP information
IPINFO_API_TOKEN="YOUR_API_KEY_HERE"

# ===============================
# FUNCTIONS
# ===============================

# Rotate Tor IP
renew_tor_ip() {
    echo -e "AUTHENTICATE \"\"\r\nSIGNAL NEWNYM\r\nQUIT" | nc 127.0.0.1 9051 >/dev/null 2>&1
}

# Analyze HTML content
check_js_cookies_forms() {
    local html="$1"
    local js_count=$(echo "$html" | grep -io '<script' | wc -l)
    local form_count=$(echo "$html" | grep -io '<form' | wc -l)
    local cookie_count=$(echo "$html" | grep -i 'Set-Cookie' | wc -l)

    echo -e "${BLUE}[+] HTML Analysis:${RESET}"
    echo -e "${CYAN}> JS Scripts: $js_count${RESET}"
    echo -e "${CYAN}> Forms: $form_count${RESET}"
    echo -e "${CYAN}> Cookies: $cookie_count${RESET}"

    if [ "$js_count" -gt 10 ] || [ "$form_count" -gt 2 ]; then
        echo -e "${RED}[!] Potential attack surface detected${RESET}"
    fi
}

# Scan common sensitive paths
scan_sensitive_paths() {
    echo -e "\n${BLUE}[+] Sensitive paths scan:${RESET}"
    local paths=(
        "/robots.txt" "/admin" "/login" "/.git" "/.env"
        "/config.php" "/wp-admin" "/wp-login.php"
    )

    for path in "${paths[@]}"; do
        code=$(curl -s -o /dev/null -w "%{http_code}" "${CURL_OPTS[@]}" "$URL$path")
        [[ "$code" == "200" ]] && echo -e "${GREEN}[+] Found: $URL$path${RESET}"
    done
}

# Resolve IP via proxychains + multiple DNS
resolve_ip() {
    local domain=$1
    local dns=("1.1.1.1" "8.8.8.8" "9.9.9.9")

    for d in "${dns[@]}"; do
        ip=$(proxychains4 dig @"$d" +short +tcp "$domain" 2>/dev/null | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)
        if [[ -n "$ip" && ! "$ip" =~ ^(10\.|192\.168\.|127\.|172\.(1[6-9]|2[0-9]|3[0-1])\.) ]]; then
            echo "$ip"
            return
        fi
    done
}

# ===============================
# EXECUTION
# ===============================
{
    echo -e "${ORANGE}[*] Checking Tor SOCKS5...${RESET}"
    if ! timeout 3 bash -c "</dev/tcp/127.0.0.1/9050" &>/dev/null; then
        echo -e "${RED}[!] Tor not available${RESET}"
        exit 1
    fi

    echo -e "${ORANGE}[*] Rotating Tor IP...${RESET}"
    renew_tor_ip
    sleep 5

    TOR_IP=$(curl -s --socks5-hostname 127.0.0.1:9050 https://api.ipify.org)
    echo -e "${GREEN}[+] Tor IP: $TOR_IP${RESET}"

    echo -e "[+] Target: $URL"
    echo -e "[+] User-Agent: $RANDOM_UA"

    echo -e "\n${BLUE}[+] HTTP Code:${RESET}"
    curl "${CURL_OPTS[@]}" -o /dev/null -w "%{http_code}\n" "$URL"

    echo -e "\n${BLUE}[+] Headers:${RESET}"
    curl "${CURL_OPTS[@]}" -I "$URL"

    echo -e "\n${BLUE}[+] Server Detection:${RESET}"
    headers=$(curl "${CURL_OPTS[@]}" -s -I "$URL")
    server=$(echo "$headers" | grep -i '^Server:' | cut -d' ' -f2-)
    [[ -n "$server" ]] && echo -e "${RED}[+] Server: $server${RESET}"

    echo -e "\n${BLUE}[+] DNS Resolution:${RESET}"
    ip=$(resolve_ip "$BASE_DOMAIN")
    if [[ -n "$ip" ]]; then
        echo -e "${GREEN}[+] IP: $ip${RESET}"

        if [[ "$IPINFO_API_TOKEN" != "YOUR_API_KEY_HERE" ]]; then
            info=$(curl -s --socks5-hostname 127.0.0.1:9050 "https://ipinfo.io/$ip?token=$IPINFO_API_TOKEN")
            org=$(echo "$info" | grep -Po '"org":\s*"\K[^"]+')
            echo -e "[+] Org: ${org:-N/A}"
        else
            echo -e "${ORANGE}[!] No API key provided (ipinfo skipped)${RESET}"
        fi
    else
        echo -e "${RED}[!] IP not resolved${RESET}"
    fi

    echo -e "\n${BLUE}[+] XSS Test:${RESET}"
    payload="weird_test"
    resp=$(curl "${CURL_OPTS[@]}" -G --data-urlencode "q=$payload" "$URL")
    echo "$resp" | grep -q "$payload" && echo -e "${RED}[!] Potential XSS${RESET}" || echo -e "[+] No XSS"

    echo -e "\n${BLUE}[+] HTML Analysis:${RESET}"
    html=$(curl "${CURL_OPTS[@]}" "$URL")
    check_js_cookies_forms "$html"

    scan_sensitive_paths

    echo -e "\n${GREEN}=== AUDIT COMPLETE ===${RESET}"

} | tee "$LOG_FILE"

 echo -e "\n${ORANGE}[*] Log saved: $LOG_FILE${RESET}"
