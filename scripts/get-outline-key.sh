#!/bin/bash

KEY_DIR="keys/outline"
KEY_FILE="${KEY_DIR}/${KEY_NAME}.json"

mkdir -p ${KEY_DIR}"
echo "==> [CONFIG] Checking required variables..."
: "${API_URL:?Missing API_URL}"
: "${KEY_NAME:?Missing KEY_NAME}"

echo "==> [GENERATE] Generating and naming access key..."
curl -k -s -X POST "$API_URL/access-keys" > $KEY_FILE
ID=$(jq -r '.id' $KEY_FILE)

curl -k -s -X PUT "$API_URL/access-keys/$ID/name" \
	-d "name=$KEY_NAME"

echo "==> [FETCH] Retrieving updated key data with name..."
curl -k -s -X GET "$API_URL/access-keys/$ID" > "$KEY_FILE"

echo "==> [SUCCESS] ${KEY_NAME} key generated and saved to ${KEY_FILE}"

echo $KEY
