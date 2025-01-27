#!/bin/bash
set -euo pipefail  # Enable strict error handling

# Load shared environment variables
source $(dirname $0)/scripts/env.sh

# Validate arguments
FORK=$1
if [ -z "$FORK" ]; then
    echo "Error: Missing FORK argument. Expected values: ['fork9', 'fork12', 'fork11']"
    exit 1
fi

DATA_AVAILABILITY_MODE=$2
if [ -z "$DATA_AVAILABILITY_MODE" ]; then
    echo "Error: Missing DATA_AVAILABILITY_MODE argument. Expected values: ['rollup', 'cdk-validium']"
    exit 1
fi

# Define the base folder
BASE_FOLDER=$(dirname $0)

# Validate the Kurtosis CLI is installed
if ! command -v kurtosis &> /dev/null; then
    echo "Error: Kurtosis CLI not found. Please install it before running this script."
    exit 1
fi

# Clean up any stale Kurtosis enclaves
echo "Cleaning up old Kurtosis enclaves..."
kurtosis clean --all

# Override the cdk config file
echo "Overriding cdk config file..."
cp "$BASE_FOLDER/config/kurtosis-cdk-node-config.toml.template" "$KURTOSIS_FOLDER/templates/trusted-node/cdk-node-config.toml"

# Run the Kurtosis test environment
echo "Running Kurtosis with combination: $FORK-$DATA_AVAILABILITY_MODE.yml"
kurtosis run --enclave cdk --args-file "combinations/$FORK-$DATA_AVAILABILITY_MODE.yml" --image-download always "$KURTOSIS_FOLDER"
