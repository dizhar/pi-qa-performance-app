#!/bin/bash 
set -e


VM_IP_ADDRESS="52.167.136.188"
VM_USERNAME="azureuser"

# SSH_PRIVATE_KEY_FILE="${PWD}/pi-qa-automation-app/pi-qa-automation-app.pem"
# SSH_PRIVATE_KEY_FILE="~/.ssh/pi-qa-automation"
SSH_PRIVATE_KEY_FILE="./pi-qa-performance-app.pem"

TARGET_DIRECTORY="~/pi-qa-automation-app"

# run from pi-qa-automation-app parent directory
# ./pi-qa-automation-app/copy.sh
# chmod 400 $SSH_PRIVATE_KEY_FILE

ssh -i $SSH_PRIVATE_KEY_FILE $VM_USERNAME@$VM_IP_ADDRESS
