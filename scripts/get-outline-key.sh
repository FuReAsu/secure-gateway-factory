#!/bin/bash

KEY_FILE="keys/outline/${KEY_NAME}.json"

echo "==> [CONFIG] Checking required variables..."
: "${API_URL:?Missing API_URL}"
: "${KEY_NAME:?Missing KEY_NAME}"

echo "==> [GENERATE] Generating and naming access key..."
curl -k -s -X POST "$API_URL/access-keys" > $KEY_FILE
ID=$(jq -r '.id' $KEY_FILE)

curl -k -s -X PUT "$API_URL/access-keys/$ID/name" \
	-d "name=$KEY_NAME"

echo "==> [SUCCESS] ${KEY_NAME} key generated..."
KEY=$(jq -r '.accessUrl' $KEY_FILE)

echo $KEY
