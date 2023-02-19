#!/bin/bash

# Check if dirb is installed
if ! command -v dirb &> /dev/null; then
  echo "Error: dirb is not installed. Please install it before running this script."
  exit 1
fi

# Check if dirbuster is installed
if ! command -v dirbuster &> /dev/null; then
  echo "Error: dirbuster is not installed. Please install it before running this script."
  exit 1
fi

# Check if nmap is installed
if ! [ -x "$(command -v nmap)" ]; then
  echo "Error: nmap is not installed. Please install nmap and try again." >&2
  exit 1
fi

# Check if target website is up and running
function check_status {
  status=$(curl -s -o /dev/null -w '%{http_code}' $1)
  if [ $status -eq 200 ]; then
    echo "Website is up and running"
  else
    echo "Website is down"
  fi
}

# Extract server information
function server_info {
  server=$(curl -sI $1)
  echo "Server information: $server"
}

# Extract IP address
function ip_address {
  ping $1 -w 12  
}


# Use nmap to scan the target website
function nmap_scan {
  echo "Starting nmap scan..."
  nmap -sV -Pn $1
}

#Use dirb to scan for the directory # Create the results directory if it doesn't exist
function dirb_scan {
#making a directory
  RESULTS_DIR="./dirb_results"
  if [ ! -d "$RESULTS_DIR" ]; then
    mkdir -p "$RESULTS_DIR"
  fi
  dirb "$1" -o "$RESULTS_DIR/dirb_results.txt"
}

#Use dirbuster to scan for the directory from the websites
function dirbuster_scan {
# Set the wordlist to use for the scan
WORDLIST="/usr/share/wordlists/dirb/common.txt"

# Set the directory to save the scan results
RESULTS_DIR="./dirbuster_results"

# Create the results directory if it doesn't exist
if [ ! -d "$RESULTS_DIR" ]; then
  mkdir -p "$RESULTS_DIR"
fi

# Run the dirbuster scan
dirbuster -u "$1" -l "$WORDLIST" -o "$RESULTS_DIR/dirbuster_results.html" -F
}

# Main function
function main {
  check_status $1
  server_info $1
  ip_address $1
  nmap_scan $1
  dirb_scan $1
  dirbuster_scan $1 
}

# Menu
while true; do
  echo "Menu:"
  echo "1. Website status check"
  echo "2. Server information"
  echo "3. IP address"
  echo "4. nmap scan"
  echo "5. Full reconnaissance"
  echo "6. Directory search using dirb"
  echo "7. Directory search using dirbuster"
  echo "8. Exit"
  read -p "Choose an option [1-8]: " option

  case $option in
    1)
      read -p "Enter target website: " website
      check_status $website
      ;;
    2)
      read -p "Enter target website: " website
      server_info $website
      ;;
    3)
      read -p "Enter target website: " website
      ip_address $website
      ;;
    4)
      read -p "Enter target website: " website
      nmap_scan $website
      ;;
    5)
      read -p "Enter target website: " website
      main $website
      ;;
    6)
      read -p "Enter target website: " website
      dirb_scan $website
      ;;
    7)
      read -p "Enter target website: " website
      dirbuster_scan $website 
      ;;
    8)
      break
      ;;
  esac
done
clear
