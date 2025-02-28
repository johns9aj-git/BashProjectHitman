#!/bin/bash

usage() {
    echo "Usage: $0 -p <port_range> -r <target_ip(s)> [-o <output_file>]"
    echo "  -p  Specify port range (e.g., 1-6500 or 22,80,443)"
    echo "  -r  Target IP(s) to scan (multiple allowed)"
    echo "  -o  (Optional) Save result to a file"
    echo "  -h  Display this help menu"
    exit 1
}

# Initialize variables
PORT_RANGE=""
TARGET_IPS=()
OUTPUT_FILE=""

# Regex for valid IP or Hostname
VALID_IP_REGEX="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
VALID_HOSTNAME_REGEX="^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$"

# Function to validate IP or hostname
validate_ip_or_hostname() {
    local input="$1"
    if [[ "$input" =~ $VALID_IP_REGEX || "$input" =~ $VALID_HOSTNAME_REGEX ]]; then
        return 0
    else
        echo "Invalid IP or Hostname: $input"
        return 1
    fi
}

while getopts "p:r:o:h" opt; do
    case $opt in
        p) PORT_RANGE=$OPTARG ;;
        r) IFS=' ' read -r -a TARGET_IPS <<< "$OPTARG" ;;
        o) OUTPUT_FILE=$OPTARG ;;
        h) usage ;;
        *) echo "Invalid option: -$OPTARG" >&2; usage ;;
    esac
done

# Validate inputs
if [[ -z "$PORT_RANGE" || ${#TARGET_IPS[@]} -eq 0 ]]; then
    echo "Error: Port range and target IP(s) are required." >&2
    usage
fi

# Validate each target IP/hostname
for ip in "${TARGET_IPS[@]}"; do
    if ! validate_ip_or_hostname "$ip"; then
        echo "Error: Invalid target IP or hostname: $ip" >&2
        exit 1
    fi
done

echo "Scanning targets: ${TARGET_IPS[@]} on ports: $PORT_RANGE"
RESULTS=""

for ip in "${TARGET_IPS[@]}"; do
    echo "Scanning $ip..."
    
    IFS=',' read -r -a PORTS <<< "$PORT_RANGE"
    
    for port in "${PORTS[@]}"; do
        if timeout 2 nc -z -v -w 1 "$ip" "$port" 2>/dev/null; then
            RESULT="$ip:$port is open"
            echo "$RESULT"
            RESULTS+="$RESULT\n"
        fi
    done
done

# Save results to file if an output file is specified
if [[ -n "$OUTPUT_FILE" ]]; then
    echo -e "$RESULTS" > "$OUTPUT_FILE"
    echo "Results saved to $OUTPUT_FILE"
fi
