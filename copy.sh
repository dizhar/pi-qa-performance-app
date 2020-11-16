#!/bin/bash 
set -e

# https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71
# https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion

# ssh -i ~/.ssh/pi-qa-automation piadmin@104.208.220.28

# VM_IP_ADDRESS="104.208.220.28"
# VM_USERNAME="piadmin"
# SSH_PRIVATE_KEY_FILE="~/.ssh/pi-qa-automation"

#  test
# http://pi-qa-performance.pilayer.net:3000/www.mrporter.com/2020-08-23-15-33-54/index.html
# http://pi-qa-performance.pilayer.net/be/www.mrporter.com/2020-08-23-15-33-54/index.html

# https://pi-qa-performance.pilayer.net/be/cashier.piesec.com/2020-09-29-08-45-18/index.html

# ssh -i ./pi-qa-performance-app.pem azureuser@52.167.136.188

# VM_IP_ADDRESS="52.191.165.91"
VM_IP_ADDRESS="52.167.136.188"
VM_USERNAME="azureuser"
SSH_PRIVATE_KEY_FILE="${PWD}/pi-qa-performance-app/pi-qa-performance-app.pem"

TARGET_DIRECTORY="~/pi-qa-performance-app"

# run from pi-qa-performance-app parent directory
# ./pi-qa-performance-app/copy.sh
chmod 400 $SSH_PRIVATE_KEY_FILE

ssh -i $SSH_PRIVATE_KEY_FILE $VM_USERNAME@$VM_IP_ADDRESS "mkdir -p $TARGET_DIRECTORY"
# ssh -i $SSH_PRIVATE_KEY_FILE $VM_USERNAME@$VM_IP_ADDRESS "mkdir -p $TARGET_DIRECTORY/nginx"

for file_or_folder in "nginx" "socket-io-nginx" "socket-io-server" "docker-compose.yaml" "docker-login.sh" "run.sh"; do
    echo "Copying $file_or_folder ..."
    scp -i $SSH_PRIVATE_KEY_FILE -r pi-qa-performance-app/${file_or_folder} $VM_USERNAME@$VM_IP_ADDRESS:$TARGET_DIRECTORY
done
