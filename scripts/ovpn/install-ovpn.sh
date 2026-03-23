#!/bin/bash

mkdir -p $HOME/ovpn
LOG_FILE="$HOME/ovpn/ovpn.log"
INSTALL_FILE="$HOME/ovpn/openvpn-install.sh"

echo "==> [CONFIG] Checking required variables..."
: "${OVPN_PORT:?Error: OVPN_PORT environment variable is not set}"

echo "==> [DOWNLOAD] Fetching OVPN installation script..."
if ! curl -sSL https://raw.githubusercontent.com/angristan/openvpn-install/cad603c484acab3cfeb53d322e9590d7ff75fe96/openvpn-install.sh -o $INSTALL_FILE; then
    echo "Failed to download installation script."
    exit 1
fi

echo "==> [INSTALL] Running OVPN installer (this may take a minute)..."

sudo bash $INSTALL_FILE install --port "$OVPN_PORT" --dns google >> $LOG_FILE

if ! [ "$?" ]; then
    echo "[ERROR] Installation failed... Please check $LOG_FILE"
	  exit 1
fi

if ! [ -f "$HOME/client.ovpn" ]; then
    echo "[ERROR] No default client file found, installation failed... Please check $LOG_FILE..."
    exit 1
fi

echo "==> [SUCCESS] OVPN server installation successful..."
