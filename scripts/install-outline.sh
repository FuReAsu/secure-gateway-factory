#!/bin/bash

echo "Checking required variables"
: "${API_PORT:?Missing API_PORTS}"
: "${KEYS_PORT:?Missing KEYS_PORTS}"

curl -L https://raw.githubusercontent.com/Jigsaw-Code/outline-apps/master/server_manager/install_scripts/install_server.sh -o install_server.sh 

RAW_CONFIG=$(yes | sudo bash install_server.sh --api-port $API_PORT --keys-port $KEYS_PORT 2>/dev/null | grep apiUrl)

echo "$RAW_CONFIG" | grep -o '{.*}' > outline-api.json
