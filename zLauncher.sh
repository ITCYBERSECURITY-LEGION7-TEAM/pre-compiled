#!/bin/bash

# Colors for UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Config paths
CCMINER_PATH="$HOME/ccminer"
CONFIG_FILE="$CCMINER_PATH/config.json"
CCMINER_BIN="$CCMINER_PATH/ccminer"

# Function to display hacker animation
hacker_animation() {
    local progress=$1
    local width=50
    local filled=$((width * progress / 100))
    local empty=$((width - filled))
    
    printf "\r${CYAN}["
    for ((i=0; i<filled; i++)); do
        printf "█"
    done
    for ((i=0; i<empty; i++)); do
        printf "▒"
    done
    printf "] ${progress}%%${NC}"
    
    # Random hacker text effect
    if (( progress % 10 == 0 )); then
        hacker_chars=("010101" "011001" "101010" "110011" "001100" "1001" "0110")
        random_char=${hacker_chars[$RANDOM % ${#hacker_chars[@]}]}
        printf " ${GREEN}${random_char}${NC}"
    fi
}

# Function to simulate loading with hacker style
simulate_hacker_loading() {
    local task_name=$1
    local duration=$2
    
    echo -e "${BLUE}▶ ${task_name}...${NC}"
    
    for i in $(seq 1 100); do
        hacker_animation $i
        sleep $(echo "scale=3; $duration/100" | bc)
    done
    echo
}

# Function to create default config
create_default_config() {
    cat > $CONFIG_FILE << EOF
{
    "pools":
        [{
            "name": "VERUS.NET",
            "url": "stratum+tcp://au.vipor.net:5040",
            "timeout": 120,
            "disabled": 0 
        [{
            "name": "VERUS.NET",
            "url": "stratum+tcp://sg.vipor.net:5040",
            "timeout": 120,
            "disabled": 0
        }],     

    "user": "$WALLET_ADDRESS.$WORKER_NAME",
    "pass": "Crypto",
    "algo": "verus",
    "threads": 8,
    "cpu-priority": 1,
    "cpu-affinity": -1,
    "retry-pause": 10,
    "api-allow": "192.168.0.0/16",
    "api-bind": "0.0.0.0:4068"
}

EOF
}

# Function to check dependencies
check_dependencies() {
    echo -e "${PURPLE}🔍 Checking dependencies...${NC}"
    
    if ! command -v bc &> /dev/null; then
        echo -e "${RED}✗ bc not found. Installing...${NC}"
        sudo apt-get update && sudo apt-get install -y bc
    fi
    
    if [ ! -d "$CCMINER_PATH" ]; then
        echo -e "${YELLOW}⚠ ccminer directory not found${NC}"
        simulate_hacker_loading "Creating ccminer directory" 0.5
        mkdir -p $CCMINER_PATH
    fi
    
    if [ ! -f "$CCMINER_BIN" ]; then
        echo -e "${YELLOW}⚠ ccminer binary not found${NC}"
        echo -e "${RED}Please ensure ccminer is installed in $CCMINER_PATH${NC}"
        exit 1
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}⚠ config.json not found${NC}"
        simulate_hacker_loading "Creating default config" 0.3
        create_default_config
    fi
}

# Function to display banner
display_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
 ██████╗ ██████╗███╗   ███╗██╗███╗   ██╗███████╗██████╗ 
██╔════╝██╔════╝████╗ ████║██║████╗  ██║██╔════╝██╔══██╗
██║     ██║     ██╔████╔██║██║██╔██╗ ██║█████╗  ██████╔╝
██║     ██║     ██║╚██╔╝██║██║██║╚██╗██║██╔══╝  ██╔══██╗
╚██████╗╚██████╗██║ ╚═╝ ██║██║██║ ╚████║███████╗██║  ██║
 ╚═════╝ ╚═════╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
EOF
    echo -e "${GREEN}           Automated Mining Launcher${NC}"
    echo -e "${YELLOW}=================================================${NC}"
    echo
}

# Function to get user input
get_user_input() {
    echo -e "${BLUE}💳 Please enter your mining details:${NC}"
    
    while true; do
        read -p "$(echo -e "${CYAN}💰 Wallet Address: ${NC}")" WALLET_ADDRESS
        if [ -n "$WALLET_ADDRESS" ]; then
            break
        else
            echo -e "${RED}✗ Wallet address cannot be empty${NC}"
        fi
    done
    
    while true; do
        read -p "$(echo -e "${CYAN}👷 Worker Name: ${NC}")" WORKER_NAME
        if [ -n "$WORKER_NAME" ]; then
            break
        else
            echo -e "${RED}✗ Worker name cannot be empty${NC}"
        fi
    done
}

# Function to update config with user input
update_config() {
    echo -e "${BLUE}⚙️  Updating configuration...${NC}"
    
    # Backup original config
    cp $CONFIG_FILE "$CONFIG_FILE.backup"
    
    # Update config with user details
    simulate_hacker_loading "Configuring miner" 0.8
    
    # Use sed to update the config file
    sed -i "s/\"user\": \".*\"/\"user\": \"$WALLET_ADDRESS.$WORKER_NAME\"/" $CONFIG_FILE
    
    echo -e "${GREEN}✅ Configuration updated successfully${NC}"
    echo -e "${YELLOW}📝 Wallet: $WALLET_ADDRESS${NC}"
    echo -e "${YELLOW}👷 Worker: $WORKER_NAME${NC}"
}

# Function to validate configuration
validate_config() {
    echo -e "${BLUE}🔍 Validating configuration...${NC}"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}✗ Config file not found${NC}"
        return 1
    fi
    
    if ! jq empty $CONFIG_FILE 2>/dev/null; then
        echo -e "${RED}✗ Invalid JSON configuration${NC}"
        return 1
    fi
    
    simulate_hacker_loading "Validating JSON structure" 0.4
    echo -e "${GREEN}✅ Configuration validated${NC}"
    return 0
}

# Function to launch miner
launch_miner() {
    echo
    echo -e "${YELLOW}=================================================${NC}"
    echo -e "${GREEN}🚀 Launching CCMiner...${NC}"
    echo -e "${YELLOW}📁 Config: $CONFIG_FILE${NC}"
    echo -e "${YELLOW}⚙️  Binary: $CCMINER_BIN${NC}"
    echo -e "${YELLOW}=================================================${NC}"
    echo
    
    # Final countdown
    for i in {5..1}; do
        echo -e "${RED}Launching in $i...${NC}"
        sleep 1
    done
    
    echo -e "${GREEN}🎯 Miner started! Press Ctrl+C to stop.${NC}"
    echo
    
    # Launch the miner
    $CCMINER_BIN -c $CONFIG_FILE
}

# Main function
main() {
    display_banner
    check_dependencies
    get_user_input
    update_config
    
    if validate_config; then
        launch_miner
    else
        echo -e "${RED}❌ Configuration validation failed${NC}"
        echo -e "${YELLOW}Attempting to restore backup...${NC}"
        cp "$CONFIG_FILE.backup" $CONFIG_FILE
        exit 1
    fi
}

# Error handling
set -e

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed
    trap 'echo -e "\n${RED}⚠ Script interrupted${NC}"; exit 1' INT TERM
    main "$@"
fi
