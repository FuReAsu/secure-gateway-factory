#!/bin/bash

mkdir -p $HOME/outline
LOG_FILE="$HOME/outline/outline.log"
INSTALL_FILE="$HOME/outline/install_server.sh"

echo "==> [CONFIG] Checking required variables..."
: "${API_PORT:?Error: API_PORT environment variable is not set}"
: "${KEYS_PORT:?Error: KEYS_PORT environment variable is not set}"

echo "==> [DOWNLOAD] Fetching Outline installation script..."
if ! curl -sSL https://raw.githubusercontent.com/Jigsaw-Code/outline-apps/master/server_manager/install_scripts/install_server.sh -o $INSTALL_FILE; then
    echo "Falled to download installation script."
    exit 1
fi

echo "==> [INSTALL] Running Outline installer (this may take a minute)..."

yes | sudo bash $INSTALL_FILE --api-port "$API_PORT" --keys-port "$KEYS_PORT" > $LOG_FILE

echo "==> [EXTRACT] Parsing API configuration..."
RAW_CONFIG=$(cat "$LOG_FILE" | grep "apiUrl" || true)

if [[ -n "$RAW_CONFIG" ]]; then
    echo "$RAW_CONFIG" | grep -o '{.*}' > outline-api.json
    echo "==> [SUCCESS] Configuration saved to outline-api.json"
    cat outline-api.json
else
    echo "==> [ERROR] Could not find apiUrl in installation output."
    exit 1
fi
