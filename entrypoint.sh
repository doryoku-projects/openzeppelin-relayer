#!/bin/sh
set -e

# Make sure config directory exists
mkdir -p /app/config

# Copy config template from mounted directory to active config path
if [ -f /app/config/config.json.template ]; then
  cp /app/config/config.json.template /app/config/config.json
else
  echo "Error: /app/config/config.json.template not found. Make sure configuration templates are mounted."
  exit 1
fi

# Replace Sepolia RPC placeholder if defined in environment variables
if [ -n "$SEPOLIA_RPC_URL" ]; then
  echo "Injecting Sepolia RPC URL..."
  sed -i "s|SEPOLIA_RPC_URL_PLACEHOLDER|${SEPOLIA_RPC_URL}|g" /app/config/config.json
else
  echo "Warning: SEPOLIA_RPC_URL environment variable is not defined."
fi

# Replace Mainnet RPC placeholder if defined in environment variables
if [ -n "$MAINNET_RPC_URL" ]; then
  echo "Injecting Mainnet RPC URL..."
  sed -i "s|MAINNET_RPC_URL_PLACEHOLDER|${MAINNET_RPC_URL}|g" /app/config/config.json
else
  echo "Warning: MAINNET_RPC_URL environment variable is not defined."
fi

echo "Configuration initialized successfully."

# Execute the official openzeppelin-relayer binary forwarding all args
exec /app/openzeppelin-relayer "$@"
