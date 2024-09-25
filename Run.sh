#!/bin/bash

# Displaying ASCII Art
echo "   _____ _    _ ____ _______       _  ________ _____  "
echo "  / ____| |  | |  _ \__   __|/\   | |/ /  ____|  __ \ "
echo " | (___ | |  | | |_) | | |  /  \  | ' /| |__  | |__) |"
echo "  \___ \| |  | |  _ <  | | / /\ \ |  < |  __| |  _  / "
echo "  ____) | |__| | |_) | | |/ ____ \| . \| |____| | \ \ "
echo " |_____/ \____/|____/  |_/_/    \_\_|\_\______|_|  \_\ "
echo "                                                       "
echo "                                                       "

# Function to create directories if they do not exist
create_directory() {
    [ ! -d "$1" ] && mkdir -p "$1"
}

# Function to create files if they do not exist
create_file() {
    [ ! -f "$1" ] && touch "$1"
}

# Check if the URL is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

url="$1"

# Create necessary directories
create_directory "$url/recon"
create_directory "$url/recon/scans"
create_directory "$url/recon/httprobe"
create_directory "$url/recon/potential_takeovers"
create_directory "$url/recon/wayback"
create_directory "$url/recon/wayback/params"
create_directory "$url/recon/wayback/extensions"

# Create necessary files
create_file "$url/recon/httprobe/alive.txt"
create_file "$url/recon/final.txt"
create_file "$url/recon/potential_takeovers/potential_takeovers.txt"

echo "[+] Finding subdomains with assetfinder..."
assetfinder "$url" | grep "$url" > "$url/recon/final.txt"

# Checking if assetfinder command was successful
if [ $? -ne 0 ]; then
    echo "[-] Failed to find subdomains with assetfinder."
    exit 1
fi

echo "[+] Searching for alive domains..."
cat "$url/recon/final.txt" | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' > "$url/recon/httprobe/alive.txt"

# Checking if httprobe command was successful
if [ $? -ne 0 ]; then
    echo "[-] Failed to find alive domains."
    exit 1
fi

echo "[+] Checking for possible subdomain takeover..."
subjack -w "$url/recon/final.txt" -t 100 -timeout 30 -ssl -v 3 -o "$url/recon/potential_takeovers/potential_takeovers.txt"

# Checking if subjack command was successful
if [ $? -ne 0 ]; then
    echo "[-] Failed to check for subdomain takeover."
    exit 1
fi

echo "[+] Scanning for open ports..."
nmap -iL "$url/recon/httprobe/alive.txt" -T4 -oA "$url/recon/scans/scanned"

# Checking if nmap command was successful
if [ $? -ne 0 ]; then
    echo "[-] Nmap scan failed."
    exit 1
fi

echo "[+] Scraping wayback data..."
waybackurls -d "$url" < "$url/recon/final.txt" > "$url/recon/wayback/wayback_output.txt"

# Checking if waybackurls command was successful
if [ $? -ne 0 ]; then
    echo "[-] Failed to scrape wayback data."
    exit 1
fi

echo "[+] Compiling possible params from wayback data..."
grep '\?*=' "$url/recon/wayback/wayback_output.txt" | cut -d '=' -f 1 | sort -u > "$url/recon/wayback/params/wayback_params.txt"
while read -r line; do
    echo "$line="
done < "$url/recon/wayback/params/wayback_params.txt"

echo "[+] Compiling js/php/aspx/jsp/json files from wayback output..."
while read -r line; do
    ext="${line##*.}"
    case "$ext" in
        js) echo "$line" >> "$url/recon/wayback/extensions/js.txt" ;;
        html) echo "$line" >> "$url/recon/wayback/extensions/jsp.txt" ;;
        json) echo "$line" >> "$url/recon/wayback/extensions/json.txt" ;;
        php) echo "$line" >> "$url/recon/wayback/extensions/php.txt" ;;
        aspx) echo "$line" >> "$url/recon/wayback/extensions/aspx.txt" ;;
    esac
done < "$url/recon/wayback/wayback_output.txt"

echo "[+] All operations completed successfully."
