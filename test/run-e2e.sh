#!/bin/bash
set -euo pipefail  

source $(dirname $0)/scripts/env.sh  # Load shared env vars

# Allow users to specify variables dynamically
export NETWORK="${NETWORK:-fork12-rollup}"
export BATS_TESTS="${BATS_TESTS:-all}"

# Allow env var inputs (including L2_ETH_RPC_URL)
export GAS_TOKEN_ADDR="${GAS_TOKEN_ADDR:-0x72ae2643518179cF01bcA3278a37ceAD408DE8b2}"

# Define the base folder
BASE_FOLDER=$(dirname $0)

# Validate the Kurtosis CLI is installed
if ! command -v kurtosis &> /dev/null; then
    echo "Error: Kurtosis CLI not found. Please install it before running this script."
    exit 1
fi

echo "Running tests for network: $NETWORK"
echo "Using L2_RPC_URL: $L2_ETH_RPC_URL"
echo "Using GAS_TOKEN_ADDR: $GAS_TOKEN_ADDR"

# Start Kurtosis with the selected network
kurtosis clean --all

echo "Overriding cdk config file..."
cp "$BASE_FOLDER/config/kurtosis-cdk-node-config.toml.template" "$KURTOSIS_FOLDER/templates/trusted-node/cdk-node-config.toml"

kurtosis run --enclave cdk --args-file "combinations/${NETWORK}.yml" --image-download always "$KURTOSIS_FOLDER"

# Run selected tests with exported environment variables
if [[ "$BATS_TESTS" == "all" ]]; then
    env bats test/
else
    # Convert comma-separated list to space-separated and prepend "test/" to each file
    BATS_TESTS_LIST=$(echo "$BATS_TESTS" | tr ',' ' ' | sed 's~[^ ]*~test/&~g')
    env bats $BATS_TESTS_LIST
fi
