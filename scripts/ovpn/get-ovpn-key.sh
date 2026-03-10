#!/bin/bash

INSTALL_FILE="$HOME/ovpn/openvpn-install.sh"
KEY_DIR="$HOME/keys/ovpn"
mkdir -p ${KEY_DIR}

echo "==> [CONFIG] Checking required variables..."
: "${KEY_NAME:?Missing KEY_NAME}"

echo "==> [GENERATE] Generating OVPN client key..."
sudo bash ${INSTALL_FILE} client add ${KEY_NAME}

mv $HOME/${KEY_NAME}.ovpn ${KEY_DIR}

echo "==> [SUCCESS] ${KEY_NAME} key generated moved to ${KEY_DIR}"
